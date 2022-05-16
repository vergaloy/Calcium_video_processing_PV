
% p.UIContextMenu = right;

function cmHandle = right_click_app()
   cmHandle = uicontextmenu;
   mitem=uimenu(cmHandle,'Label','delete');
   mitem.MenuSelectedFcn = @delfunc;
end

function delfunc(src,event)
disp('hola mundo')
end