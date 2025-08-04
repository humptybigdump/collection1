function bwthresh(img)

    % turn image into black-and-white using treshold 0.5 (127/255),
    % display it and get handle to image object
    hImage = imshow(im2bw(img,0.5));
    
    % create slider control to adjust threshold
    uicontrol('Style', 'slider',...
        'Units','normalized',...
        'Min',0,'Max',255,'Value',127,'SliderStep',[1/255 0.2],...
        'Position', [0.2 0.05 0.6 0.02],...
        'Callback', @threshSliderCallback);
    
    % create text box to display current threshold
    threshText = uicontrol('Style','text',...
        'FontSize',14,...
        'Units','normalized',...
        'Position',[0.45 0.005 0.1 0.03],...
        'String',127);

    % function to execute, when slider is moved
    function threshSliderCallback(hObject,~)
        % get slider value
        threshold = get(hObject,'Value');
        
        % replace data of image object with newly tresholded image
        set(hImage,'CData',im2bw(img,threshold/255));
        
        % update text box
        set(threshText,'String',round(threshold))
    end

end