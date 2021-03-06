function [hObject, eventdata, handles] = goToXYZ(hObject, eventdata, handles, position)
targetX = position(1);
targetY = position(2);
targetZ = position(3);

[hObject, eventdata, handles] = getCurrentXY(hObject, eventdata, handles);
curX = handles.stageX;
curY = handles.stageY;

accuracy = 10;      % edit this to change the positional accuracy in um

% move X
set(handles.stageStatus, 'String', 'Moving X', 'ForegroundColor', [0,0,1]);
guidata(hObject, handles);
while abs(targetX-curX) >= accuracy
    diff = round(targetX-curX,-1);      % round to the nearest 10
    % if diff > 0, that means stage should move to right (inc)
    % else stage should move to left (dec)
    if diff > 0
        diff = min(3000, diff);
        [hObject, eventdata, handles] = setXStep(hObject, eventdata, handles, diff);
        [hObject, eventdata, handles] = incX(hObject, eventdata, handles);
    else
        diff = abs(diff);
        diff = min(3000, diff);
        [hObject, eventdata, handles] = setXStep(hObject, eventdata, handles, diff);
        [hObject, eventdata, handles] = decX(hObject, eventdata, handles);
    end
    pause(.5);      % max movement takes about 0.5 second to finish
    done = false;
    while ~done
        [hObject, eventdata, handles, done] = getCurrentXY(hObject, eventdata, handles);
    end
    curX = handles.stageX;
end
set(handles.stageStatus, 'String', 'Done with X', 'ForegroundColor', [0,0,1]);
guidata(hObject, handles);


% move Y
set(handles.stageStatus, 'String', 'Moving Y', 'ForegroundColor', [0,0,1]);
guidata(hObject, handles);
while abs(targetY-curY) >= accuracy
    diff = round(targetY-curY, -1);     % round to the nearest 10
    % if diff > 0, that means stage should move up (inc)
    % else stage should move down (dec)
    if diff > 0
        diff = min(3000, diff);
        [hObject, eventdata, handles] = setYStep(hObject, eventdata, handles, diff);
        [hObject, eventdata, handles] = incY(hObject, eventdata, handles);
    else
        diff = abs(diff);
        diff = min(3000, diff);
        [hObject, eventdata, handles] = setYStep(hObject, eventdata, handles, diff);
        [hObject, eventdata, handles] = decY(hObject, eventdata, handles);
    end
    pause(.5);      % max movement takes about 0.5 second to finish
    [hObject, eventdata, handles] = getCurrentXY(hObject, eventdata, handles);
    curY = handles.stageY;
end
set(handles.stageStatus, 'String', 'Done with Y', 'ForegroundColor', [0,0,1]);
guidata(hObject, handles);


% move Z
set(handles.stageStatus, 'String', 'Moving Z', 'ForegroundColor', [0,0,1]);
guidata(hObject, handles);
[hObject, eventdata, handles] = goToZ(hObject, eventdata, handles, targetZ);
pause(1);       % TODO: replace this line with checking whether Z stage is still moving

[hObject, eventdata, handles] = getCurrentZ(hObject, eventdata, handles);
set(handles.stageStatus, 'String', 'Done with Z', 'ForegroundColor', [0,0,1]);
guidata(hObject, handles);


% update GUI with current position
[hObject, eventdata, handles] = updatePos(hObject, eventdata, handles);
guidata(hObject, handles);

set(handles.stageStatus, 'String', 'In position', 'ForegroundColor', [0,0,1]);
guidata(hObject, handles);
end