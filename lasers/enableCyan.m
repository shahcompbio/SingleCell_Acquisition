function [hObject, eventdata, handles] = enableCyan(hObject, eventdata, handles)
cyanOnCmd = sscanf('4F 7B 50', '%2X');
fwrite(handles.laserConnection, cyanOnCmd, 'uint8');
guidata(hObject, handles);
end