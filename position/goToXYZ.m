function [hObject, eventdata, handles] = goToXYZ(hObject, eventdata, handles, position)
targetX = position(1);
targetY = position(2);
targetZ = position(3);

[hObject, eventdata, handles] = getCurrentXY(hObject, eventdata, handles);
[hObject, eventdata, handles] = getCurrentZ(hObject, eventdata, handles);
curX = handles.stageX;
curY = handles.stageY;
curZ = handles.stageZ;

accuracy = 10;      % edit this to change the positional accuracy in um
% move X
while abs(targetX-curX) >= accuracy
    % move here
    disp('Moving X');
    diff = targetX-curX;
    % if diff > 0, that means stage should move to right (inc)
    % else stage should move to left (dec)
    if diff > 0
        diff = min(1000, diff);
        [hObject, eventdata, handles] = setXStep(hObject, eventdata, handles, diff);
        [hObject, eventdata, handles] = incX(hObject, eventdata, handles);
    else
        diff = abs(diff);
        diff = min(1000, diff);
        [hObject, eventdata, handles] = setXStep(hObject, eventdata, handles, diff);
        [hObject, eventdata, handles] = decX(hObject, eventdata, handles);
    end
    [hObject, eventdata, handles] = getCurrentXY(hObject, eventdata, handles);
    curX = handles.stageX;
end
disp('Done moving X');

% move Y
while abs(targetY-curY) >= accuracy
    % move here
    disp('Moving Y');
    diff = targetY-curY;
    % if diff > 0, that means stage should move up (inc)
    % else stage should move down (dec)
    if diff > 0
        diff = min(1000, diff);
        [hObject, eventdata, handles] = setYStep(hObject, eventdata, handles, diff);
        [hObject, eventdata, handles] = incY(hObject, eventdata, handles);
    else
        diff = abs(diff);
        diff = min(1000, diff);
        [hObject, eventdata, handles] = setYStep(hObject, eventdata, handles, diff);
        [hObject, eventdata, handles] = decY(hObject, eventdata, handles);
    end
    [hObject, eventdata, handles] = getCurrentXY(hObject, eventdata, handles);
    curY = handles.stageY;
end
disp('Done moving Y');

% move Z
while abs(targetZ-curZ) >= accuracy
    % move here
    disp('TODO: move Z');
    [hObject, eventdata, handles] = getCurrentZ(hObject, eventdata, handles);
    curZ = handles.stageZ;
end

end