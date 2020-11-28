function [hObject, eventdata, handles] = acquire(hObject, eventdata, handles, laserIndex)
lasers = {'UV', 'Blue', 'Cyan', 'Teal', 'Green', 'Red'};

    function goToTile(handles, row, col)
       disp(['going to tile row ', num2str(row), ' col ', num2str(col)]);
       % do things here. remember to check for the state within here as
       % well
       pause(0.5);
    end

    function [hObject, eventdata, handles] = turnOnLaser(hObject, eventdata, handles, laser)
        disp(['Turning on laser ', char(lasers(laser))]);
        set(handles.status, 'String', ['Turning on laser ', char(lasers(laser))]);
        guidata(hObject, handles);
%         pause(0.5);
    end

    function figure = splitImage(image, row, col, r, c)
        %{
        image: image to be split
        row: total number of rows in image
        col: total number of columns columns in image
        r: the rth row of the image (1-indexed)
        c: the cth column of the image (1-indexed)
        return: the split image at rth row and cth column
        %}
        height = size(image, 1);
        width = size(image, 2);
        figure = image(((height/row)*(r-1))+1:((height/row)*r),((width/col)*(c-1))+1:(width/col)*c);
    end

    function saveImage(well, tileRow, tileCol, row, col, r, c, folderPath, laserIndex)
        chipRow = (tileRow-1) * row + r;
        chipCol = (tileCol-1) * col + c;
        rowStr = ['R', num2str(chipRow, '%02d')];
        colStr = ['C', num2str(chipCol, '%02d')];
        colDir = fullfile(folderPath, colStr);
        if ~exist(colDir, 'dir')
            disp(['Making column directory for ', colStr]);
            mkdir(colDir)
        end

        laserStr = num2str(laserIndex-1, '%02d');
        filename = [rowStr, '_', colStr, '_0000_', laserStr, '_', laser, '.tif'];
        filepath = fullfile(colDir, filename);
        imwrite(well, filepath);
        disp(['Saving image at ', filepath]);
    end

    function takeNsaveImage(handles, tileRow, tileCol, folderPath, laserIndex)
        disp('Taking image');
        pause(0.5);
        laser = char(lasers(handles.curLaser));
        % image obtained here
        image = imitateLiveView(666, 999);
        row = handles.imgRow;
        col = handles.imgCol;
        
        % split columns in each row
        % then go to another row and repeat
        for r = 1:row
            for c = 1:col
                well = splitImage(image, row, col, r, c);
%                 well = im2uint16(well);
                % calculate the indices of row and column
                % in the entire chip
                saveImage(well, tileRow, tileCol, row, col, r, c, folderPath, laserIndex);
                pause(0.5);
            end
        end
        pause(0.5);
    end

    function handles = acquireTile(handles, row, col, folderPath, laserIndex)
        %{
        handles: GUI handle
        row: which tile in row to go to (each tile contains 
            imgRow*imgCol numbers of wells)
        col: which tile in column to go to
        folderPath: the folder at ./<laser>/S0000
        return: none
        %}
        goToTile(handles, row, col);
        takeNsaveImage(handles, row, col, folderPath, laserIndex);
    end

% set up
guidata(hObject, handles);
[hObject, eventdata, handles] = turnOnLaser(hObject, eventdata, handles, handles.curLaser);
laser = char(lasers(handles.curLaser));
laserDir = fullfile(handles.outputDir, laser);
curDir = fullfile(laserDir, 'S0000');
if ~exist(laserDir, 'dir')
    disp(['Making new laser directory at ', laserDir]);
    mkdir(laserDir);
end
if ~exist(curDir, 'dir')
    disp(['Making new chip directory at ', curDir]);
    mkdir(curDir)
end

% acquisition
ii = handles.curRow;
jj = handles.curCol;
% for i = ii:handles.chipRow/handles.imgRow
%     for j = jj:handles.chipCol/handles.imgCol
for i = ii:2
    for j = jj:2
        if (get(handles.pauseORresume, 'Value') == 0)
            handles.paused = false;
            handles = acquireTile(handles, i, j, curDir, laserIndex);
            handles.curCol = handles.curCol + 1;
        else
            handles.paused = true;
            break;
        end
    end
    guidata(hObject, handles);
    if handles.paused
        break;
    else
        handles.curRow = handles.curRow + 1;
        handles.curCol = 1;
        jj = 1;
    end
    guidata(hObject, handles);
end


if handles.paused || get(handles.pauseORresume, 'Value') == 1
    set(handles.status, 'String', 'Paused', 'ForegroundColor', [0, 0, 1]);
    set(handles.pauseORresume, 'String', 'Resume', 'enable',' on');
    set(handles.Quit, 'enable', 'on');
    disp('paused');
    waitfor(handles.pauseORresume, 'Value', 0);
else
    disp('continue');
    handles.curRow = 1;
    handles.curCol = 1;
end
guidata(hObject, handles);
end