%maximal number of samples for a row
number_of_samples = 3;
ind = [];

%find samples for or all classes
for i=unique(code')
temp = find(code == i);
ind = [ind temp(find(temp(1:min(length(temp),number_of_samples))))];
end;

%plot chernoff faces
figure;
glyphplot(d_org(ind,parameter.gui.merkmale_und_klassen.ind_em),'glyph','face','obslabels',{zgf_y_bez(par.y_choice,code(ind)).name})