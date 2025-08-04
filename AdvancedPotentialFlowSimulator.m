
% -----------------------------------------------------------------------------
% Potential flow solver for superposition of elemental solutions of laplace 	%
% equation and modelling the potential flow around airfoils with the 			%
% singularities method.                 										%
%																				%
% Written by Zacharias Kraus, TU Darmstadt, Germany in August 2016				%
% ----------------------------------------------------------------------------- %

function varargout = AdvancedPotentialFlowSimulator(varargin)

	% Begin initialization code
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
	                   'gui_Singleton',  gui_Singleton, ...
	                   'gui_OpeningFcn', @AdvancedPotentialFlowSimulator_OpeningFcn, ...
	                   'gui_OutputFcn',  @AdvancedPotentialFlowSimulator_OutputFcn, ...
	                   'gui_LayoutFcn',  [] , ...
	                   'gui_Callback',   []);
	if nargin && ischar(varargin{1})
	    gui_State.gui_Callback = str2func(varargin{1});
	end

	if nargout
	    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
	    gui_mainfcn(gui_State, varargin{:});
	end
	% End initialization code
function varargout = AdvancedPotentialFlowSimulator_OutputFcn(hObject, eventdata, handles) 

	% Get default command line output from handles structure
	varargout{1} = handles.output;

	% --- Executes during object creation, after setting all properties.
	function elementMenu_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end

	set(hObject,'String',{'Freestream','Source/Sink','Doublet','Vortex'});

% Executes just before AdvancedPotentialFlowSimulator is made visible
function AdvancedPotentialFlowSimulator_OpeningFcn(hObject, eventdata, handles, varargin)
	% Choose default command line output for potential
	handles.output = hObject;

	% Suppress annoying warnings that don't have any effect
	warning('off','MATLAB:contour:ConstantData');

	% Initialize velocity potential and stream function as empty, symbolic 0x2
	% matrices. Furthermore, initialize string arrays for velocity potential
	% and stream function for potential output.
	handles.phi = sym(@(x,y) zeros(0,2));
	handles.psi = sym(@(x,y) zeros(0,2));
	handles.phiStr = cell(0,3);
	handles.psiStr = cell(0,3);
	% Set default options for plot (meshsize, axes limits, streamline mesh)
	handles.meshsize 		= 0.04;
	handles.maxX 			= 1;
	handles.minX 			= -1;
	handles.maxY 			= 1;
	handles.minY 			= -1;
	handles.sldy 			= 1;
	handles.particleSpeed 	= 0.01;
	handles.beta1	 		= 0.5;
	handles.beta2	 		= 40;
	% % Test Values
% 	handles.meshsize 		= 0.05;
% 	handles.maxX 			= 1.1;
% 	handles.minX 			= -0.1;
% 	handles.maxY 			= 0.6;
% 	handles.minY 			= -0.6;
% 	handles.sldy 			= 1;
% 	handles.particleSpeed 	= 0.01;
% 	handles.beta1	 		= 0.5;
% 	handles.beta2	 		= 40;
	% Create box around axis and set axis limits
	box(handles.axes1,'on');
	axis(handles.axes1,[handles.minX handles.maxX handles.minY handles.maxY]);

	% Initialize SLA logo for settings
	handles.slaImage = imshow('sla.png', 'Parent', handles.slaAxes);
	
	% Initialize table with empty data
	data = [];
	set(handles.uitable1,'data',data);
	% Initialize element counter
	handles.elementCounter = 0;

	% No airfoil is loaded
	handles.airfoilData = [];
	handles.airfoilUpdateNecessary = 0;
	
	% Get path to script
	scriptName = mfilename;
	handles.scriptPath = mfilename('fullpath');
	handles.scriptPath = handles.scriptPath(1:(end-size(scriptName,2)));


	% Set initial visibility velocity and pressure visualization
	handles.streamCheckValue 	= 1;
	handles.potCheckValue 		= 0;
	handles.pressCheckValue 	= 0;
	handles.vecCheckValue 		= 0;
	handles.altViewCheckValue 	= 0;
	handles.symbCheckValue 		= 0;
	handles.cpPlotCheckValue 	= 0;
	handles.xFoilCheckValue 	= 0;
	handles.aniCheckValue 		= 0;
	handles.scaleCheckValue 	= 0;
	handles.equalCheckValue 	= 1;
	set(handles.streamCheck,'Value',handles.streamCheckValue);
	set(handles.potCheck,'Value',handles.potCheckValue);
	set(handles.pressCheck,'Value',handles.pressCheckValue);
	set(handles.vecCheck,'Value',handles.vecCheckValue);
	set(handles.altViewCheck,'Value',handles.altViewCheckValue);
	set(handles.symbCheck,'Value',handles.symbCheckValue);
	set(handles.cpPlotCheck,'Value',handles.cpPlotCheckValue);
	set(handles.xFoilCheck,'Value',handles.xFoilCheckValue);
	set(handles.aniCheck,'Value',handles.aniCheckValue);
	set(handles.scaleCheck,'Value',handles.scaleCheckValue);
	set(handles.equalCheck,'Value',handles.equalCheckValue);
	if handles.aniCheckValue == true
		set(handles.particleButton,'Enable','on');
		set(handles.particleButton,'ForegroundColor','k');
	else
		set(handles.particleButton,'Enable','inactive');
		set(handles.particleButton,'ForegroundColor',[.5,.5,.5]);
	end
	% Initialize color bar visibility
	handles.colorbarVisible = 0;
	handles.cL = [];
	% Set initial visibility of axis
	set(handles.axes1,'visible','on')
	set(handles.cpAxes,'visible','off')
	set(handles.slaImage,'visible','off');
	% Set initial visibility of settings text
	set(handles.textMeshsize,'visible','off')
	set(handles.textSLDY,'visible','off')
	set(handles.textBeta1,'visible','off')
	set(handles.textBeta2,'visible','off')
	set(handles.textMaxX,'visible','off')
	set(handles.textMinX,'visible','off')
	set(handles.textMaxY,'visible','off')
	set(handles.textMinY,'visible','off')
	% Set initial visibility of settings edit boxes
	set(handles.editMeshsize,'visible','off')
	set(handles.editSLDY,'visible','off')
	set(handles.editBeta1,'visible','off')
	set(handles.editBeta2,'visible','off')
	set(handles.editMaxX,'visible','off')
	set(handles.editMinX,'visible','off')
	set(handles.editMaxY,'visible','off')
	set(handles.editMinY,'visible','off')
	% Write default values into settings edit boxes
	set(handles.editMeshsize,'String',handles.meshsize)
	set(handles.editSLDY,'String',handles.sldy)
	set(handles.editBeta1,'String',handles.beta1)
	set(handles.editBeta2,'String',handles.beta2)
	set(handles.editMaxX,'String',handles.maxX)
	set(handles.editMinX,'String',handles.minX)
	set(handles.editMaxY,'String',handles.maxY)
	set(handles.editMinY,'String',handles.minY)
	% Set initial visibility of check boxes
	set(handles.streamCheck,'visible','off')
	set(handles.potCheck,'visible','off')
	set(handles.pressCheck,'visible','off')
	set(handles.vecCheck,'visible','off')
	set(handles.altViewCheck,'visible','off')
	set(handles.symbCheck,'visible','off')
	set(handles.cpPlotCheck,'visible','off')
	set(handles.xFoilCheck,'visible','off')
	set(handles.aniCheck,'visible','off')
	set(handles.scaleCheck,'visible','off')
	set(handles.equalCheck,'visible','off')
	% Hide third text and textbox, because the default element
	% is freestream, which doesn't need a third input.
	set(handles.posXText,'String','Angle')
	set(handles.posYText,'visible','off')
	set(handles.posYEdit,'visible','off')
	% Show axis navigation buttons
	set(handles.yMaxPlusButton,'visible','on')
	set(handles.yMaxMinusButton,'visible','on')
	set(handles.yMinPlusButton,'visible','on')
	set(handles.yMinMinusButton,'visible','on')
	set(handles.yPanel,'visible','on')
	set(handles.yText,'visible','on')
	set(handles.xMaxPlusButton,'visible','on')
	set(handles.xMaxMinusButton,'visible','on')
	set(handles.xMinPlusButton,'visible','on')
	set(handles.xMinMinusButton,'visible','on')
	set(handles.xPanel,'visible','on')
	set(handles.xText,'visible','on')

	% If the OS is Windows, set the font size to 8
	compOS = computer;
	if strcmp(compOS,'PCWIN64') == true || strcmp(compOS,'PCWIN') == true
		set(handles.elementMenu,'Position',[922 526 95 26])

		set(handles.editMeshsize,'FontSize',8)
		set(handles.editSLDY,'FontSize',8)
		set(handles.editBeta1,'FontSize',8)
		set(handles.editBeta2,'FontSize',8)
		set(handles.editMaxX,'FontSize',8)
		set(handles.editMinX,'FontSize',8)
		set(handles.editMaxY,'FontSize',8)
		set(handles.editMinY,'FontSize',8)

		set(handles.streamCheck,'FontSize',8)
		set(handles.potCheck,'FontSize',8)
		set(handles.pressCheck,'FontSize',8)
		set(handles.vecCheck,'FontSize',8)
		set(handles.altViewCheck,'FontSize',8)
		set(handles.symbCheck,'FontSize',8)
		set(handles.cpPlotCheck,'FontSize',8)
		set(handles.xFoilCheck,'FontSize',8)
		set(handles.aniCheck,'FontSize',8)
		set(handles.scaleCheck,'FontSize',8)
		set(handles.equalCheck,'FontSize',8)

		set(handles.elementMenu,'FontSize',8)
		set(handles.strengthEdit,'FontSize',8)
		set(handles.strengthText,'FontSize',8)
		set(handles.posXEdit,'FontSize',8)
		set(handles.posXText,'FontSize',8)
		set(handles.posYEdit,'FontSize',8)
		set(handles.posYText,'FontSize',8)
		set(handles.okbutton,'FontSize',8)
		set(handles.resetButton,'FontSize',8)
		set(handles.particleButton,'FontSize',8)
		set(handles.airFoilLoadButton,'FontSize',8)
		set(handles.settingsButton,'FontSize',8)
		set(handles.expFigButton,'FontSize',8)
		set(handles.expPotButton,'FontSize',8)
		set(handles.expDatButton,'FontSize',8)
		set(handles.redrawButton,'FontSize',8)
		set(handles.cLText,'FontSize',8)

		set(handles.textMeshsize,'FontSize',8)
		set(handles.textSLDY,'FontSize',8)
		set(handles.textBeta1,'FontSize',8)
		set(handles.textBeta2,'FontSize',8)
		set(handles.textMaxX,'FontSize',8)
		set(handles.textMinX,'FontSize',8)
		set(handles.textMaxY,'FontSize',8)
		set(handles.textMinY,'FontSize',8)
	end

	% Get window and axes position and set it as default position
	handles.windowDefaultPosition = get(gcf,'Position');
	axesPositionTemp = get(handles.axes1,'Position');
	% Calculate the position of every element in respect to the border it should
	% stick to. 
	handles.windowSize 	= [handles.windowDefaultPosition(3) handles.windowDefaultPosition(4) 0 0];
	handles.windowSizeAxes = [0 0 handles.windowDefaultPosition(3) handles.windowDefaultPosition(4)];
	handles.windowSizeCPAxes = [handles.windowDefaultPosition(3) 0 0 handles.windowDefaultPosition(4)];	

	xPosition = axesPositionTemp(1) + (axesPositionTemp(3))/2;
	yPosition = axesPositionTemp(2) + axesPositionTemp(4)/2;

	handles.windowXAxesButtonSettings = [xPosition 0 0 0];
	handles.windowYAxesButtonSettings = [0 yPosition 0 0];
	handles.windowSizeSettings = [xPosition handles.windowDefaultPosition(4) 0 0];

	handles.windowSizeCL = [handles.windowSize(1) 0 0 0];

	handles.elementMenuDefaultPosition 		= get(handles.elementMenu,'Position') 		- handles.windowSize;
	handles.strengthEditDefaultPosition 	= get(handles.strengthEdit,'Position') 		- handles.windowSize;
	handles.strengthTextDefaultPosition 	= get(handles.strengthText,'Position') 		- handles.windowSize;
	handles.posXEditDefaultPosition 		= get(handles.posXEdit,'Position') 			- handles.windowSize;
	handles.posXTextDefaultPosition 		= get(handles.posXText,'Position') 			- handles.windowSize;
	handles.posYEditDefaultPosition 		= get(handles.posYEdit,'Position') 			- handles.windowSize;
	handles.posYTextDefaultPosition 		= get(handles.posYText,'Position') 			- handles.windowSize;
	handles.okButtonDefaultPosition 		= get(handles.okbutton,'Position') 			- handles.windowSize;
	handles.resetButtonDefaultPosition 		= get(handles.resetButton,'Position') 		- handles.windowSize;
	handles.particleButtonDefaultPosition 	= get(handles.particleButton,'Position')	- handles.windowSize;
	handles.airFoilLoadButtonDefaultPosition= get(handles.airFoilLoadButton,'Position') - handles.windowSize;
	handles.settingsDefaultPosition 		= get(handles.settingsButton,'Position') 	- handles.windowSize;
	handles.expFigButtonDefaultPosition 	= get(handles.expFigButton,'Position') 		- handles.windowSize;
	handles.expPotButtonDefaultPosition 	= get(handles.expPotButton,'Position') 		- handles.windowSize;
	handles.expDatButtonDefaultPosition 	= get(handles.expDatButton,'Position') 		- handles.windowSize;
	handles.cLTextDefaultPosition 			= get(handles.cLText,'Position') 			- handles.windowSizeCL;

	handles.tableDefaultPosition 			= get(handles.uitable1,'Position') 			- handles.windowSize;

	handles.streamCheckDefaultPosition 		= get(handles.streamCheck,'Position') 		- handles.windowSizeSettings;
	handles.potCheckDefaultPosition 		= get(handles.potCheck,'Position') 			- handles.windowSizeSettings;
	handles.pressCheckDefaultPosition 		= get(handles.pressCheck,'Position') 		- handles.windowSizeSettings;
	handles.vecCheckDefaultPosition 		= get(handles.vecCheck,'Position') 			- handles.windowSizeSettings;
	handles.altViewCheckDefaultPosition 	= get(handles.altViewCheck,'Position') 		- handles.windowSizeSettings;
	handles.symbCheckDefaultPosition 		= get(handles.symbCheck,'Position') 		- handles.windowSizeSettings;
	handles.cpPlotCheckDefaultPosition 		= get(handles.cpPlotCheck,'Position') 		- handles.windowSizeSettings;
	handles.xFoilCheckDefaultPosition 		= get(handles.xFoilCheck,'Position') 		- handles.windowSizeSettings;
	handles.aniCheckDefaultPosition 		= get(handles.aniCheck,'Position') 			- handles.windowSizeSettings;
	handles.scaleCheckDefaultPosition 		= get(handles.scaleCheck,'Position') 		- handles.windowSizeSettings;
	handles.equalCheckDefaultPosition 		= get(handles.equalCheck,'Position') 		- handles.windowSizeSettings;

	handles.editMeshsizeDefaultPosition 	= get(handles.editMeshsize,'Position') 		- handles.windowSizeSettings;
	handles.editSLDYDefaultPosition 		= get(handles.editSLDY,'Position') 			- handles.windowSizeSettings;
	handles.editBeta1DefaultPosition 		= get(handles.editBeta1,'Position') 		- handles.windowSizeSettings;
	handles.editBeta2DefaultPosition 		= get(handles.editBeta2,'Position') 		- handles.windowSizeSettings;
	handles.editMaxXDefaultPosition 		= get(handles.editMaxX,'Position') 			- handles.windowSizeSettings;
	handles.editMinXDefaultPosition 		= get(handles.editMinX,'Position') 			- handles.windowSizeSettings;
	handles.editMaxYDefaultPosition 		= get(handles.editMaxY,'Position') 			- handles.windowSizeSettings;
	handles.editMinYDefaultPosition 		= get(handles.editMinY,'Position') 			- handles.windowSizeSettings;

	handles.textMeshsizeDefaultPosition 	= get(handles.textMeshsize,'Position') 		- handles.windowSizeSettings;
	handles.textSLDYDefaultPosition 		= get(handles.textSLDY,'Position') 			- handles.windowSizeSettings;
	handles.textBeta1DefaultPosition 		= get(handles.textBeta1,'Position') 		- handles.windowSizeSettings;
	handles.textBeta2DefaultPosition 		= get(handles.textBeta2,'Position') 		- handles.windowSizeSettings;
	handles.textMaxXDefaultPosition 		= get(handles.textMaxX,'Position') 			- handles.windowSizeSettings;
	handles.textMinXDefaultPosition 		= get(handles.textMinX,'Position') 			- handles.windowSizeSettings;
	handles.textMaxYDefaultPosition 		= get(handles.textMaxY,'Position') 			- handles.windowSizeSettings;
	handles.textMinYDefaultPosition 		= get(handles.textMinY,'Position') 			- handles.windowSizeSettings;

	handles.axesDefaultPosition 			= get(handles.axes1,'Position') 			- handles.windowSizeAxes;
	handles.cpAxesDefaultPosition 			= get(handles.cpAxes,'Position') 			- handles.windowSizeCPAxes;
	handles.slaAxesDefaultPosition 			= get(handles.slaAxes,'Position') 			- handles.windowSizeSettings;

	handles.yMaxPlusButtonDefaultPosition 	= get(handles.yMaxPlusButton,'Position') 	- handles.windowYAxesButtonSettings;
	handles.yMaxMinusButtonDefaultPosition 	= get(handles.yMaxMinusButton,'Position') 	- handles.windowYAxesButtonSettings;
	handles.yMinPlusButtonDefaultPosition 	= get(handles.yMinPlusButton,'Position') 	- handles.windowYAxesButtonSettings;
	handles.yMinMinusButtonDefaultPosition 	= get(handles.yMinMinusButton,'Position') 	- handles.windowYAxesButtonSettings;
	handles.yPanelDefaultPosition 			= get(handles.yPanel,'Position') 			- handles.windowYAxesButtonSettings;
	handles.yTextDefaultPosition 			= get(handles.yText,'Position') 			- handles.windowYAxesButtonSettings;
	
	handles.xMaxPlusButtonDefaultPosition 	= get(handles.xMaxPlusButton,'Position') 	- handles.windowXAxesButtonSettings;
	handles.xMaxMinusButtonDefaultPosition 	= get(handles.xMaxMinusButton,'Position') 	- handles.windowXAxesButtonSettings;
	handles.xMinPlusButtonDefaultPosition 	= get(handles.xMinPlusButton,'Position') 	- handles.windowXAxesButtonSettings;
	handles.xMinMinusButtonDefaultPosition 	= get(handles.xMinMinusButton,'Position') 	- handles.windowXAxesButtonSettings;
	handles.xPanelDefaultPosition 			= get(handles.xPanel,'Position') 			- handles.windowXAxesButtonSettings;
	handles.xTextDefaultPosition 			= get(handles.xText,'Position') 			- handles.windowXAxesButtonSettings;

	% Update handles structure
	guidata(hObject,handles);

% ............................ Potential Generation ............................

function [phi,psi,phistr,psistr] = genPot(varargin)

	% ------------------------------------------------------------------------- %
	% Generates potential of element based on element type, strength, position 	%
	% and angle. To supress singularities, where the velocity diverges, the 	%
	% potential of sources, doublets and vortices is modified. 					%
	%																			%
	% Input:																	%
	% type...	[string]	Type of object										%
	% s...		[1x1 num]	Intensity										 	%
	% xc... 	[1x1 num]	X-position OR angle of freestream in radians		%
	% yc... 	[1x1 num]	Y-position											%
	% x... 		[1x1 sym]	Symbolic variable x									%
	% y... 		[1x1 sym]	Symbolic variable y									%
	%																			%
	% Output:																	%
	% phi...	[1x1 sym]	Velocity potential of object						%
	% psi...	[1x1 sym]	Stream function of object							%
	% phistr...	[string]	Velocity potential as LaTeX string					%
	% psistr...	[string]	Stream function as LaTex string						%
	% ------------------------------------------------------------------------- %

	% Get type from input
	type = varargin{1};

	% Add potential of desired element
	switch type
		case 'freestream'
				s = varargin{2};
				alpha = varargin{3};
				x = varargin{4};
				y = varargin{5};
				% Calculate velocity potential and stream function
				phi = s*(x*cos(alpha)+y*sin(alpha));
				psi = s*(x*sin(alpha)+y*cos(alpha));
				% Generate LaTeX strings
				if cos(alpha) >= 10^(-6) && sin(alpha) >= 10^(-6)
					phistr = sprintf('%5g\\cdot\\left(x\\cdot\\cos(%5g) + y\\cdot\\sin(%5g)\\right)',[s,alpha,alpha]);
					psistr = sprintf('%5g\\cdot\\left(x\\cdot\\sin(%5g) + y\\cdot\\cos(%5g)\\right)',[s,alpha,alpha]);
				elseif cos(alpha) >= 10^(-6)
					phistr = sprintf('%5g\\cdot\\left(x\\cdot\\cos(%5g)\\right)',[s,alpha]);
					psistr = sprintf('%5g\\cdot\\left(y\\cdot\\cos(%5g)\\right)',[s,alpha]);
				elseif sin(alpha) >= 10^(-6)
					phistr = sprintf('%5g\\cdot\\left(y\\cdot\\sin(%5g)\\right)',[s,alpha]);
					psistr = sprintf('%5g\\cdot\\left(x\\cdot\\sin(%5g)\\right)',[s,alpha]);
				end

		case 'source'
				s = varargin{2};
				xc = varargin{3};
				yc = varargin{4};
				x = varargin{5};
				y = varargin{6};
				% Calculate velocity potential and stream function
				phi = (s/(2*pi)*log(sqrt((x-xc)^2+(y-yc)^2)));
				psi = (s)*atan2((y-yc),(x-xc))/(2*pi);
				% Generate LaTeX strings
				phistr = sprintf('\\frac{%5g}{2\\pi}\\cdot \\log\\left(\\sqrt{ (x-%5g)^2 + (y-%5g)^2 }  \\right)  ',[s,xc,yc]);
				psistr = sprintf('\\frac{%5g}{2\\pi}\\cdot \\arctan{\\left( \\frac{y-%5g}{x-%5g} \\right)}',[s,yc,xc]);
		case 'doublet'
				s = varargin{2};
				xc = varargin{3};
				yc = varargin{4};
				x = varargin{5};
				y = varargin{6};
				% Calculate velocity potential and stream function
				phi = (s*(x-xc))/(2*pi*(((x-xc)^2+(y-yc)^2)));
				psi = (-s)/(2*pi*sqrt((x-xc)^2+(y-yc)^2))*sign(y-yc)*sin(acos(x/sqrt((x-xc)^2+(y-yc)^2)));
				% Generate LaTeX strings
				phistr = sprintf('\\frac{%5g}{2\\pi} \\cdot \\frac{x-%5g}{ (x-%5g)^2 + (y-%5g)^2 } ',[s,xc,xc,yc]);
				psistr = sprintf('\\frac{%5g}{2\\pi} \\cdot \\sin{\\left(\\arctan{\\left(\\frac{y-%5g}{x-%5g}  \\right)  }\\right)} ',[-s,yc,xc]);
		case 'vortex'
				s = varargin{2};
				xc = varargin{3};
				yc = varargin{4};
				x = varargin{5};
				y = varargin{6};
				% Calculate velocity potential and stream function
 				phi = (s*atan2((y-yc),(x-xc)))/(2*pi);
				psi = (-s/(2*pi)*log(sqrt((x-xc)^2+(y-yc)^2)));
				% Generate LaTeX strings
				phistr = sprintf('\\frac{%5g}{2\\pi}\\cdot \\arctan{\\left( \\frac{y-%5g}{x-%5g} \\right)}  ',[-s,yc,xc]);
				psistr = sprintf('\\frac{%5g}{2\\pi}\\cdot \\log{\\sqrt{(x-%5g)^2 + (y-%5g)^2}}  ',[s,xc,yc]);
	end

% .................................... Plot ....................................

function [colorbarVisible, streamSpeed] = plotAxes(hObject, handles)

	% ------------------------------------------------------------------------- %
	% Plot velocity field, streamlines, equipotential lines and pressure 		%
	% distribution based on the velocity potential of all elements. If an 		%
	% airfoil is loaded, its contour is also visualized.		 				%
	%																			%
	% Output:																	%
	% colorbarVisible...[1x1 logical]											%
	% streamSpeed...	[cell]	Contains information for streamline animation	%
	% ------------------------------------------------------------------------- %


	% If the streamparticle animation is still running, stop it by changing the
	% string of particleButton
	if strcmp(get(handles.particleButton,'String'),'Stop Particles') == true
		set(handles.particleButton,'String','Start Particles')
	end

	% Initialize symbolic variables x and y
	syms x y
	% Create and clear plot axes
	axes(handles.axes1);
	cla(handles.axes1);
	cla(handles.cpAxes);

	% Get x and y data from all elements in the table.
	tableData = get(handles.uitable1,'data');

	% Only attempt to plot something if at least one element was entered
	if isempty(tableData) == false
		% Begin plot

		% Summate velocity potential and stream function of every element. This 
		% equals the superposition of all elements, which is possible due to the 
		% linearity of Laplace's equation.
		phisum = 0;
		psisum = 0;
		elmsize = size(handles.phi);
		for i=1:elmsize(1)
			phisum = phisum + handles.phi(i,2);
			psisum = psisum + handles.psi(i,2);
		end

		% Create symbolic functions of velocity field, velocity potential and
		% stream function
		um = matlabFunction(diff(phisum,x),'Vars',[x,y]);
		vm = matlabFunction(diff(phisum,y),'Vars',[x,y]);
		phim = matlabFunction(phisum,'Vars',[x,y]);
		psim = matlabFunction(psisum,'Vars',[x,y]);

		% Create a mesh to evaluate the velocity field on in
		[x y] = meshgrid(handles.minX:handles.meshsize:handles.maxX,handles.minY:handles.meshsize:handles.maxY);

		% Make sure that the mesh always lies in the origin
		yZero = find(y(:,1) >= 0,1,'first');
		y = y - y(yZero,1);

		xZero = find(x(1,:) >= 0,1,'first');
		x = x - x(1,xZero);

		% Discretize velocity field and potential on the mesh
		ud = arrayfun(um,x,y);
		vd = arrayfun(vm,x,y);
		phip = arrayfun(phim,x,y);
		psip = arrayfun(psim,x,y);

		% Write the velocity field to a file
		% dlmwrite('us',ud)
		% dlmwrite('vs',vd)

		% Every Source, Sink, Vortex and Doublet creates a singularity at its
		% origin. To prevent the velocity to diverge at this points, they are
		% excluded from the plot.
		
		% Get the x and y values of all elements
		xValues = cell2mat(tableData(1:end,4));
		yValues = cell2mat(tableData(1:end,5));
		typeValues = tableData(1:end,2);

		% Get x and y values where the mesh startes
		xmin = min(abs(x(1,:)));
		[minlip, minlop] = ismember(xmin, x(1,:));
		[minlin, minlon] = ismember(-xmin, x(1,:));
		if minlip == 1
			xmin = x(1,minlop);
		elseif minlin == 1
			xmin = x(1,minlon);
		else
			xmin = 0;
		end

		ymin = min(abs(y(:,1)));
		[minlip, minlop] = ismember(ymin, y(:,1));
		[minlin, minlon] = ismember(-ymin, y(:,1));
		if minlip == 1
			ymin = y(minlop,1);
		elseif minlin == 1
			ymin = y(minlon,1);
		else
			ymin = 0;
		end	

		% Get the x and y values which are next to the singularities
		xValues = round(xValues./handles.meshsize).*handles.meshsize + xmin;
		yValues = round(yValues./handles.meshsize).*handles.meshsize + ymin;
		[xli,xlo] = ismember(round(xValues,10),round(x(1,:),10));
		[yli,ylo] = ismember(round(yValues,10),round(y(:,1),10));
		% Set the velocity, the velocity potential and the stream function to 0
		% at these points. Comment the next lines to see what happens if the
		% modification isn't applied.

		for i = 1:max(size(xlo))
			if xli(i) == 1 && yli(i) == 1
				ud(ylo(i),xlo(i)) = 0;
				vd(ylo(i),xlo(i)) = 0;
				try
					phip(ylo(i),xlo(i)) = (phip(ylo(i)+1,xlo(i))+phip(ylo(i)-1,xlo(i)))/2;
				catch
					phip(ylo(i),xlo(i)) = 0;
				end
				psip(ylo(i),xlo(i)) = 0;
			end
		end

		% Initialize variable if cL is shown in the warning text
		cLshow = 0;


		% Plot cP distribution
		if isempty(handles.airfoilData) == false

			% Sometimes the streamparticle animation causes the calculation to
			% get stuck. This can only be aborted by the user, so a hint is
			% given. The hint vanishes when the calculation succeeded.
			if handles.aniCheckValue == 1
				set(handles.warningText,'String','The precalculation of the streamparticle animation is taking longer than it should. Please interrupt the process and disable particle animation for this scenario.')
			else
				set(handles.warningText,'String','')
			end

			% Find the index of x = 0, where the airfoil starts. If the mesh
			% doesn't contain x = 0, take the next bigger value. It should
			% include x = 0, though.
			xCPStart = find(x(1,:) >= 0,1,'first');

			% Create the grid for airfoil evaluation
			if x(1,xCPStart) >= 0 
				countCP = 1/handles.meshsize - 1;
			else
				countCP = 1/handles.meshsize;
			end
			xCP = 0:1:countCP;
			xCP = xCP + xCPStart;

			% Initialize arrays
			vUCP = [];
			vUCPCMP = [];
			vLCP = [];

			% Initialize array to save the area the airfoil covers
			airfoilMatrix = zeros(size(x,1),size(x,2));

			% Already get the velocity on the airfoil surface for cp calculation
			for i = 1:(countCP+1)

				% Get the index of the x-value corresponding to the momentary position
				xxCPlo = find(handles.xx >= x(1,xCP(i)),1,'first');

				% Get the values of the upper/lower airfoil surface for this x-value
				zUCP = handles.zU(xxCPlo);
				zLCP = handles.zL(xxCPlo);

				% For the upper and lower airfoil surface, find the meshpoints
				% above and below the airfoil surface, get the velocity on those
				% two points and lineary interpolate the velocity on the exact
				% airfoil surface.

				% Upper surface

				nextZUCPIndex = find(y(:,1) >= zUCP,1,'first');
				lastZUCPIndex = nextZUCPIndex - 1;
				% Get the next and the last y value
				nextYValue = y(nextZUCPIndex,1);
				lastYValue = y(lastZUCPIndex,1);
				if lastYValue ~= 0
					% Get the distance to the surrounding meshpoints and lineary
					% interpolate the velocity in between.
					distZY = (zUCP - lastYValue)/(nextYValue - lastYValue);
					nextVUCP = ((1-distZY)*sqrt(ud(lastZUCPIndex,xCP(i))^2 + vd(lastZUCPIndex,xCP(i))^2) + distZY*sqrt(ud(nextZUCPIndex,xCP(i))^2 + vd(nextZUCPIndex,xCP(i))^2));
					vUCP = [vUCP,nextVUCP];
				else
					% If the lower y-value is on the x-axis, don't bother its
					% velocity, it is zero anyway
					nextVUCP = (sqrt(ud(nextZUCPIndex,xCP(i))^2 + vd(nextZUCPIndex,xCP(i))^2));
					vUCP = [vUCP,nextVUCP];
				end

				% Lower surface, same here

				nextZLCPIndex = find(y(:,1) >= zLCP,1,'first') - 1;
				lastZLCPIndex =  nextZLCPIndex + 1;

				nextYValue = y(nextZLCPIndex,1);
				lastYValue = y(lastZLCPIndex,1);
				if lastYValue ~= 0
					distZY = (zLCP - lastYValue)/(nextYValue - lastYValue);
					nextVLCP = ((1-distZY)*sqrt(ud(lastZLCPIndex,xCP(i))^2 + vd(lastZLCPIndex,xCP(i))^2) + distZY*sqrt(ud(nextZLCPIndex,xCP(i))^2 + vd(nextZLCPIndex,xCP(i))^2));
					vLCP = [vLCP,nextVLCP];
				else
					nextVLCP = (sqrt(ud(nextZLCPIndex,xCP(i))^2 + vd(nextZLCPIndex,xCP(i))^2));
					vLCP = [vLCP,nextVLCP];
				end

				% Write all points covered by the airfoil for this x-value into
				% an array.
				airfoilMatrix((lastZLCPIndex+1):(lastZUCPIndex-1),xCP(i)) = 1;

				vUCP(1) = vLCP(1);

				% Get uInf and alpha
				[uInf, alpha] = getUInfAlpha(hObject,handles);

				% Calculate the cP values for the upper/lower surface
				cPU = 1-(vUCP./uInf).^2;
				cPL = +1-(vLCP./uInf).^2;

				% Get lowest value of pressure distribution on surface
				cPM = min(min(min(cPU)),min(min(cPL)));
			end

			% The airfoilMatrix is 0 on meshpoints covered by the airfoil and 1
			% everywhere else
			airfoilMatrix = 1 - airfoilMatrix;
			
			if handles.cpPlotCheckValue == true

				% Initialize axis for cP Plot
				axes(handles.cpAxes);
				set(handles.cpAxes,'visible','on')

				% Create meshpoints from 0 to 1
				xCPn = xCP - xCPStart;
				xCPn = xCPn/xCPn(end);
				% Plot the cP distribution
				hold(handles.cpAxes,'on')
				pCp = plot(handles.cpAxes,xCPn(1:end),cPU,'k');
				pCp = plot(handles.cpAxes,xCPn(1:end),cPL,'k');
				set(handles.cpAxes,'YDir','Reverse')
				xlabel(handles.cpAxes,'X')
				% ylabel(handles.cpAxes,'$c_P$','Interpreter','LaTex','FontSize',14)
				ylabel(handles.cpAxes,'cP   ','Interpreter','none')
				set(get(handles.cpAxes,'YLabel'),'Rotation',pi/2);

				% Consult xfoil for additional cP/x calcualtion if desired
				if handles.xFoilCheckValue == true

					% Use the MATLAB - xfoil interface
					xf = XFOIL([handles.xFoilPath, handles.xFoilName]);
					xf.KeepFiles = false;
					xf.Visible = false;

					% Pass on the airfoil data
					xf.Airfoil = Airfoil([handles.filepath handles.filename]);

					% Xfoil is able to filter the data to make it smoother
					xf.addFiltering(5);

					% Calculate the cP distribution for alpha
					xf.addActions({'OPER'});
					xf.addActions({'Iter';'100'});
					xf.addAlpha(alpha/pi*180,true);

					% And write it to a temp file
					xf.addPressureFile(['tempCpData.txt']);

					% Execute the calculations
					xf.run;

					% The next command might be executed before the OS updates
					% the file system which results in an error, hence MATLAB
					% should wait.
					pause(0.25)

					% Read the temp file created by xfoil. It contains the cP/x values.
					xFoilCpData = table2array(readtable([pwd, '\tempCpData.txt'],'Format','%f %f'));
					xFoilX = xFoilCpData(:,1);
					xFoilCp = xFoilCpData(:,2);

					% Plot the cP/x values calculated by xfoil
					pXCp = plot(handles.cpAxes,xFoilX,xFoilCp,'r');
					set(handles.cpAxes,'YDir','Reverse')

					% Delete the temp files
					delete(sprintf('%s\\actions_*.txt',pwd))
					delete(sprintf('%s\\tempCpData.txt',pwd))
					delete(sprintf('%s\\tp*.dat',pwd))

					% Add a legend to the cP plot so the data out of xfoil and
					% from this tool can be distinguished
					legend(handles.cpAxes,'on');
					legend(handles.cpAxes,[pCp, pXCp],'Singularities Method','Panel Method');
				% else
				% 	legend(handles.cpAxes,'on');
				% 	legend(handles.cpAxes,[pCp],'Singularities Method');
				end

				hold(handles.cpAxes,'off')

				% Set the x-axis limits to -0.05 and 1.05 but automatically scale the y-axis
				axis(handles.cpAxes,[-0.05 1.05 0 1]);
				axis(handles.cpAxes, 'auto y')
				box(handles.cpAxes,'on')

				% Show cL value
				clshow = 1;

			elseif get(handles.cpAxes,'visible') == true
				set(handles.cpAxes,'visible','off')
			end
		end

		hold(handles.axes1,'on')

		% Plot pressure distribution
		if handles.pressCheckValue == 1

			% Bernoulli's equation for two-dimensional irrotational, steady,
			% incompressible flow: rho/2*(u^2+v^2) + p = C, whereas C is a
			% arbitrary constant along one streamline. In  potential flow, C is
			% constant not only along one streamline, but in the entire system.
			% Because there is no fluid surface, it is legit to set the
			% arbitrary constant to zero. Furthermore, the pressure will be
			% scaled afterwards, so the constant factor rho/2 can be neglected.
			% Thus the pressure  distribution can be calculated with:
			% p = -(ud.^2.+vd.^2);

			% Instead, the pressure coefficient is calculated, if it exsists (if a freestream was added):
			try 
				[uInf, alpha] = getUInfAlpha(hObject,handles);
				v = sqrt(ud.^2.+vd.^2);
				p = 1-(v./uInf).^2;
			catch
				p = -(ud.^2.+vd.^2);
			end

			% If an airfoil is loaded, exclude the pressure values inside the airfoil.
			aM = 0; 
			try
				isempty(airfoilMatrix);
				aM = 1;
			end
			if aM == 1
				p(find(airfoilMatrix==0)) = (max(max(p)) + min(min(p)))/2;
			end

			% Normalize the pressure distribution, so the highest value is 0
			% p = p - max(max(p)) + 1;
			% cp = (p - p inf) / (q inf)
			if max(max(p)) == min(min(p))
				p = zeros(size(p));
			else
				% p = (p - max(max(p)))/(max(max(p))-min(min(p))) + 1;
			end

			% On the singularities location, set the pressure to the median of 
			% the surrounding pressure.
			p(ylo,xlo) = (p(ylo+1,xlo)+p(ylo-1,xlo))/2;

			% Make a vector of all p values
			pVec = reshape(p,[],1);

			% Sort that vector
			pVec = sort(pVec);

			% Create smooth curves

			pVecGlatt = [];
			for i = 1:(max(size(pVec)))
				pVecGlatt = [pVecGlatt, (pVec( max((i-2),1) )/8  + pVec(max((i-1),1))/4  + pVec(i)/4 + pVec(min((i+2),max(size(pVec))))/4  + pVec(min((i+2),max(size(pVec))))/8 )];
			end
			
			pVecGlatt2 = [];
			for i = 1:(max(size(pVecGlatt)))
				pVecGlatt2 = [pVecGlatt2, (pVecGlatt( max((i-2),1) )/8  + pVecGlatt(max((i-1),1))/4  + pVecGlatt(i)/4 + pVecGlatt(min((i+2),max(size(pVecGlatt))))/4  + pVecGlatt(min((i+2),max(size(pVecGlatt))))/8 )];
			end

			pVecGlatt3 = [];
			for i = 1:(max(size(pVecGlatt)))
				pVecGlatt3 = [pVecGlatt3, (pVecGlatt2( max((i-2),1) )/8  + pVecGlatt2(max((i-1),1))/4  + pVecGlatt2(i)/4 + pVecGlatt2(min((i+2),max(size(pVecGlatt2))))/4  + pVecGlatt2(min((i+2),max(size(pVecGlatt))))/8 )];
			end

			% The pressure in areas with a high pressure gradient should be
			% equally visable as areas with a low gradient. Therefore a line
			% of positive steepness is added.

			% steepness = 0.5;
			steepness = handles.beta1;
			for i = 1:max(size(pVec))
				pVecLin(i) = pVec(i) + i/max(size(pVec))*(max(max(pVec))-min(min(pVec)))*(steepness);
			end

			% pax = axes(figure);
			% hold(pax,'on')
			% pvp = plot(pax,pVec);
			% pvg = plot(pax,pVecGlatt3);
			% pvl = plot(pax,pVecLin);
			% legend(pax,[pvp,pvl,pvg],'pVec','pVecLin','pVecGlatt3')
			% hold(pax,'off')

			% smallstep = 40;
			smallstep = handles.beta2;

			% If the minimum of the pressure distribution on the airfoil
			% surface was calculated, use that as minimum pressure.
			try 
				cPM;
			catch
				cPM = min(min(pVec));
			end

			c = [cPM];
			% Calculate the pressure values for the contour plot
			% for i = 1:smallstep
			% 	% pIndex = find(pVecLin(:,:) >= ((i-1)*(max(max(p))+  (max(max(pVec))-min(min(pVec)))*(1/2)   -min(min(p))))/smallstep+min(min(p)),1,'first');
			% 	% pIndex = find(pVecLin(:,:) >= ((i-1)*(max(max(p))+  (max(max(pVec))-cPM)*(steepness)   -cPM))/smallstep+cPM,1,'first');
			% 	pIndex = find(pVecLin(:,:) >= ((i-1)*(max(max(pVecLin))-cPM))/smallstep+cPM,1,'first');
			% 	if isempty(pIndex) == false
			% 		if c(end) < pVec(pIndex)
			% 			c(end+1) = pVec(pIndex);
			% 		else
			% 			j = 0;
			% 			while true
			% 				if (pIndex + j) < max(size(pVec))
			% 					if pVec(pIndex + j) > c(end)
			% 						c(end+1) = pVec(pIndex+j);
			% 						break
			% 					end
			% 					j = j+1;
			% 				else
			% 					break
			% 				end
			% 			end
			% 		end
			% 	else
			% 		c = 0;
			% 		break
			% 	end
			% end
			for i = 1:smallstep
				% pIndex = find(pVecLin(:,:) >= ((i-1)*(max(max(p))+  (max(max(pVec))-min(min(pVec)))*(1/2)   -min(min(p))))/smallstep+min(min(p)),1,'first');
				% pIndex = find(pVecLin(:,:) >= ((i-1)*(max(max(p))+  (max(max(pVec))-cPM)*(steepness)   -cPM))/smallstep+cPM,1,'first');
				pIndex = find(pVecLin(:,:) >= ((i-1)*(max(max(pVecLin))-cPM))/smallstep+cPM,1,'first');
				if isempty(pIndex) == false
					if c(end) ~= pVecGlatt3(pIndex)
						c(end+1) = pVecGlatt3(pIndex);
					else
						j = 0;
						while true
							if (pIndex + j) < max(size(pVec))
								if pVecGlatt3(pIndex + j) ~= c(end)
									c(end+1) = pVecGlatt3(pIndex+j);
									break
								end
								j = j+1;
							else
								break
							end
						end
					end
				else
					c = 0;
					break
				end
			end

			% Plot pressure distribution and color legend
			contourf(handles.axes1,x,y,p,c,'k','LineColor',[0.7,0.7,0.7],'LineWidth',0.01);
			colormap(handles.axes1,'jet');
			colorbar('peer',handles.axes1);
			% climax = get(handles.axes1,'CLim');
			% if isempty(handles.airfoilData) == false
			% 	set(handles.axes1,'CLim',[min(min(pVec)),1])
			% else
			% 	set(handles.axis1,'CLim',[min(min(pVec)),max(max(pVec))])
			% end
			colorbarVisible = 1;
		else
			colorbar(handles.axes1,'off');
			colorbarVisible = 0;
		end

		% Plot potential lines
		if handles.potCheckValue == 1
			if handles.altViewCheckValue == 1
				% Exclude inf and NaN
				phip(~isfinite(phip))=0;
				phiSpace = linspace(min(min(phip)),max(max(phip)),10);
				contour(handles.axes1,x,y,phip,phiSpace,'k');
			else
				contour(handles.axes1,x,y,phip,'k');
			end
		end

		streamSpeed = 0;

		% Plot streamlines
		if handles.streamCheckValue == 1
			if handles.altViewCheckValue == 1
				% Alternative method: 
				psip(~isfinite(psip))=0;
				try
					psiSpace = linspace(min(min(psip)),max(max(psip)),10);
				catch
					psiSpace = 0;
				end
				try % If psip isn't real, don't plot it
					contour(handles.axes1,x,y,psip,psiSpace,'b');
				end
			else
				% Create mesh for streamlines and plot streamlines
				stry1 = transpose(handles.minY:handles.sldy*handles.meshsize:handles.maxY);

				yZero = find(stry1(:,1) >= 0,1,'first');
				stry1 = stry1 - stry1(yZero,1);

				% Left edge
				strx1 = zeros(size(stry1,1),1) + handles.minX;

				% Calculate the next meshpoint by the angle of the entering
				% stream at the current point.

				% Lower edge
				strx2(1) = handles.minX;
				while true
					if strx2(end) < handles.maxX
						% find the next meshpoint
						nextXIndex = find(x(1,:) >= strx2(end),1,'first');
						if isempty(nextXIndex) == true
							break
						end
						% If the velocity at the next point is not zero, calculate the next point
						if abs(vd(1,nextXIndex)) <= 10^(-5) || abs(ud(1,nextXIndex)) <= 10^(-5)
							strx2(end) = strx2(end)+handles.meshsize;
						else
							strx2 = [strx2;strx2(end)+handles.sldy*handles.meshsize*abs(ud(1,nextXIndex)/vd(1,nextXIndex))];
						end
					else
						strx2(end) = [];
						break	
					end
				end

				if isempty(strx2) == false
					if strx2(end) >= (handles.maxX - handles.meshsize)
						strx2(end) = [];
					elseif strx2(1) <= (handles.minX + handles.meshsize)
						strx2(1) = [];
					end
				end

				if isempty(strx2) == true
					stry2 = [];
				else
					stry2 = zeros(size(strx2,1),1) + handles.minY;
				end

				% Upper edge
				strx3(1) = handles.minX;
				while true
					if strx3(end) < handles.maxX
						nextXIndex = find(x(end,:) >= strx3(end),1,'first');
						if isempty(nextXIndex) == true
							break
						end
						if abs(vd(end,nextXIndex)) <= 10^(-5) || abs(ud(end,nextXIndex)) <= 10^(-5)
							strx3(end) = strx3(end)+handles.meshsize;
						elseif vd(end,nextXIndex) > 0
							strx3(end) = strx3(end)+handles.meshsize;
						else
							strx3 = [strx3;strx3(end)+handles.sldy*handles.meshsize*abs(ud(end,nextXIndex)/vd(end,nextXIndex))];
						end
					else
						strx3(end) = [];
						break
					end
				end
				
				if isempty(strx3) == false
					if strx3(end) >= (handles.maxX - handles.meshsize)
						strx3(end) = [];
					elseif strx3(1) <= (handles.minX + handles.meshsize)
						strx3(1) = [];
					end
				end

				if isempty(strx3) == true
					stry3 = [];
				else
					stry3 = zeros(size(strx3,1),1) + handles.maxY - handles.meshsize;
				end

				% Try to plot the streamlines. If it doesn't succeed on the
				% upper and lower edge, just take the left side.
				try 
					strx = [strx1;strx2;strx3];
					stry = [stry1;stry2;stry3];

					verts = stream2(x,y,ud,vd,strx,stry);
					streamline(handles.axes1,verts);
					if handles.aniCheckValue == 1
						streamSpeed = interpstreamspeed(x,y,ud,vd,verts,handles.particleSpeed);
					else
						streamSpeed = 1;
					end
				catch
					strx = [strx1];
					stry = [stry1];

					verts = stream2(x,y,ud,vd,strx,stry);
					streamline(handles.axes1,verts);
					if handles.aniCheckValue == 1
						streamSpeed = interpstreamspeed(x,y,ud,vd,verts,handles.particleSpeed);
					else
						streamSpeed = 1;
					end
				end
			end
		end

		% If the particle animation didn't fail, remove the warning and show cL instead.
		if cLshow == 1
			set(handles.warningText,'String',sprintf('cL = %1.3f',handles.cL))
		else
			set(handles.warningText,'String','')
		end

		% Plot velocity vector field
		if handles.vecCheckValue == 1
			if handles.scaleCheckValue == 1
				% Exclude the velocity inside the airfoil if one is loaded
				aM = 0; try, isempty(airfoilMatrix); aM = 1; end;
				if aM == 1	
					uq = ud .* airfoilMatrix;
					vq = vd .* airfoilMatrix;
				else
					uq = ud;
					vq = vd;
				end
				quiver(handles.axes1,x,y,uq,vq);
			else
				% If the vector length shouldn't be scaled, normalize the velocity.
				uq = ud./sqrt(ud.^2 + vd.^(2));
				vq = vd./sqrt(ud.^2 + vd.^(2));

				% Exclude the velocity inside the airfoil if one is loaded
				aM = 0; try, isempty(airfoilMatrix); aM = 1; end;
				if aM == 1
					uq = uq .* airfoilMatrix;
					vq = vq .* airfoilMatrix;
				end
				uq(~isfinite(uq)) = 0;
				vq(~isfinite(vq)) = 0;
				quiver(handles.axes1,x,y,uq,vq,'AutoScaleFactor',0.7);
			end
		end

		% In an airfoil is loaded, visualize it
		if isempty(handles.airfoilData) == false
			patch(handles.axes1,handles.airfoilData(:,1),handles.airfoilData(:,2),'white','LineWidth',2)
			% patch(handles.axes1,handles.airfoilData(:,1),handles.airfoilData(:,2),'white','LineWidth',2, 'FaceAlpha',0.4)
		end

		% Plot element symbols if so desired
		if handles.symbCheckValue == 1
			missing = 0;
			for i = 1:size(tableData,1)
				if strcmp(typeValues{i},'Source/Sink') == true
					plot(handles.axes1,xValues(i-missing),yValues(i-missing),'s','MarkerSize',8,'MarkerFaceColor','r')
				elseif strcmp(typeValues{i},'Doublet') == true
					plot(handles.axes1,xValues(i-missing),yValues(i-missing),'s','MarkerSize',8,'MarkerFaceColor','b')
				elseif strcmp(typeValues{i},'Vortex') == true
					plot(handles.axes1,xValues(i-missing),yValues(i-missing),'s','MarkerSize',8,'MarkerFaceColor','g')
				elseif strcmp(typeValues{i},'Freestream') == true
					missing = missing + 1;
				end
			end
		end

		hold(handles.axes1,'off')

		% If the axis should be scaled equally, set the axis limits accordingly
		if handles.equalCheckValue == false
			axis(handles.axes1,[handles.minX handles.maxX handles.minY handles.maxY]);
		end
		box(handles.axes1,'on')
		set(gca,'Layer','top')
	else
		colorbarVisible = 0;
		streamSpeed = [];
	end

	figure1_SizeChangedFcn(hObject, [], handles)

	% If velocity potential is displayed, update it
	try
		a = get(handles.potFig,'Visible');
	end
	if exist('a') ~= 0
		elmsize = size(handles.phiStr);
		if elmsize(1) ~= 0
			phiStr = [handles.phiStr{1,2}];
			psiStr = [handles.psiStr{1,2}];
			for i=2:elmsize(1)
				phiStr = [phiStr,sprintf('+') , handles.phiStr{i,2}];
				psiStr = [psiStr,sprintf('+') , handles.psiStr{i,2}];
			end
			phiStr(strfind(phiStr,' ')) = [];
			psiStr(strfind(psiStr,' ')) = [];
			phiStr = [sprintf('$\\varphi = ') phiStr sprintf('$')];
			psiStr = [sprintf('$\\psi = ') phiStr sprintf('$')];
		else
			phiStr = '$\\varphi = 0$';
			psiStr = '$\\psi = 0$';
		end
		if isempty(handles.airfoilData) == true
			set(handles.potLabel,'String',phiStr)
		else
			set(handles.potLabel,'String','When an airfoil has been loaded, the potential is too long to show it here. However, it has been copied to the clipboard as LaTeX code')
		end
		set(handles.warningText,'String','The potential function has been copied to the clipboard.')
		clipboard('copy',phiStr)
	end

% ....................... Airfoil Generation and Update ........................

function airFoilLoadButton_Callback(hObject, eventdata, handles)

    % ------------------------------------------------------------------------- %
    % Load airfoil data from .dat file and calculate the vortex/source 			%
	% distribution accordingly. 												%
	% ------------------------------------------------------------------------- %

	% Get path to .dat file via UI.
	[handles.filename,handles.filepath]=uigetfile({'*.*','All Files'},'Please select airfoil data file');

	% Do nothing if cancel was pressed
	if ischar(handles.filename) == true && ischar(handles.filepath) == true
		handles.airfoilData = table2array(readtable([handles.filepath handles.filename]));
		% On Windows, the produced array is a cell array containing strings for
		% each line. Therefor the strings are extracted from the array and
		% converted to numbers. On Mac OS X, table2array produces a double
		% array, which is sufficient for further use
		if strcmp(class(handles.airfoilData),'double') == false
			for i = 1:size(handles.airfoilData,1)
				[tmpAFD(i,:),b] = str2num(handles.airfoilData{i,:});
			end
			handles.airfoilData = tmpAFD;
		end
		% The only way the new generated data can be written into the handles
		% array is assigning the output of generateAirfoil to the entries of
		% handles. Updating handles inside generateAirfoil is not possible,
		% because all handles will set back to previous state if the function is
		% finished.

		startIndex = handles.elementCounter + 1;
		% Generate usable airfoil data and calculate the velocity potential
		[handles.xx, handles.zU, handles.zL, handles.f, phiAF, psiAF, phiStrAF, psiStrAF, handles.elementCounter, airfoilTable, handles.cL, lednicer] = generateAirfoil(hObject,handles,startIndex);

		% Omit the first entry if the airfoil is in lednicer format. It contains
		% how many entries there are and is therefore not relevant.
		if lednicer == 1
			handles.airfoilData(1,:) = [];
		end

		% Update velocity potential, stream function and table
		handles.phi = [handles.phi;phiAF];
		handles.psi = [handles.psi;psiAF];
		handles.phiStr = [handles.phiStr;phiStrAF];
		handles.psiStr = [handles.psiStr;psiStrAF];
		oldData = get(handles.uitable1,'data');
		newData = [oldData; airfoilTable];
		set(handles.uitable1,'data',newData);
		handles.symbCheckValue = 0;
		set(handles.symbCheck,'Value',handles.symbCheckValue);

		% Set the axis limits so the full airfoil is shown.
		if isempty(handles.airfoilData) == false && handles.minX >= 0
			handles.minX = -0.1;
			set(handles.editMinX,'String',handles.minX)
		end
		if isempty(handles.airfoilData) == false && handles.maxX <= 1
			handles.maxX = 1.1;
			set(handles.editMaxX,'String',handles.maxX)
		end
		if isempty(handles.airfoilData) == false && handles.minY >= min(min(handles.zL))
			handles.minY = min(min(handles.zL))+min(min(handles.zU))/10;
			set(handles.editMinY,'String',handles.minY)
		end
		if isempty(handles.airfoilData) == false && handles.maxX <= max(max(handles.zU))
			handles.maxY = max(max(handles.zU))+max(max(handles.zU))/10;
			set(handles.editMaxY,'String',handles.maxY)
		end

		% Check whether the xfoil location is known and get it if it isn't
		try 
			ex = isempty(handles.xFoilLocation);
		end
		if handles.xFoilCheckValue == true && exist('ex') == false
			if exist([handles.scriptPath,'xfoil.exe'],'file') == 2
				% Load xFoil if it is in the same location
				handles.xFoilPath = handles.scriptPath;
				handles.xFoilName = 'xfoil.exe';
				% handles.xFoilLocation = [handles.scriptPath,'xfoil.exe'];
			else
				% If it isn't, let the user point to its location
				[handles.xFoilName, handles.xFoilPath] = uigetfile({'*.*','All Files'},'Please select xfoil.exe');
				% handles.xFoilLocation = [xFoilPath,xFoilName];
			end
		end

		% Update plot
		[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);

		% Show cL value
		set(handles.cLText,'String',sprintf('cL = %2f',handles.cL))

		% Update handles structure
		guidata(hObject, handles);
	else
		set(handles.warningText,'String','Warning: No airfoil has been loaded.')
	end
function [newPhi, newPsi, newPhiStr, newPsiStr, newTable, newXx, newZU, newZL, newF, newElementCounter, cL] = updateAirfoil(hObject,handles)
		
    % ------------------------------------------------------------------------- %
	% Update the aifoil, necessary if e.g. the meshsize has changed.			%
	%																			%
	% Output:																	%
	% newPhi...			[1xm sym]	Updated array of velocity potential 		%
	% newPsi...			[1xm sym]	Updated array of stream function 			%
	% newPhiStr...		[1xm cell]	Updated string array of velocity potential 	%
	% newPsiStr...		[1xm cell]	Updated string array of stream function 	%
	% newTable...		[nx6 cell]	Updated entries of table 					%
	% newXx...			[1xo num]	Updated vector of x values 					%
	% newZU...			[1xo num]	Updated upper airfoil contour 				%
	% newZL...			[1xo num]	Updated lower airfoil contour 				%
	% newF...			[1xo num]	Updated mean camber line 					%
	% newElementCounter [1x1 num]	New number of elements 						%
	% cL 				[1x1 num]	Lift coefficent 	 						%
	% -------------------------------------------------------------------------	%

	% Get arrays of velocity potential, stream function and table in previous
	% state
	oldPhi = handles.phi;
	oldPsi = handles.psi;
	oldPhiStr = handles.phiStr;
	oldPsiStr = handles.psiStr;
	oldTable = get(handles.uitable1,'data');

	% Get size of phi before changes
	sizeOldPhi = size(oldPhi,1);

	% Create a vector of indices of entries of old phi array where the no
	% airfoil data is stored

	aIndex = [];
	for i = 1:sizeOldPhi
		if strcmp(char(oldPhi(i,3)),'N')
			aIndex = [aIndex,i];
		end
	end

	% Prepare new arrays with the old data that is passed on
	newPhi = [];
	newPsi = [];
	newPhiStr = [];
	newPsiStr = [];
	newTable = [];
	for j = 1:max(size(aIndex))
		newPhi = [newPhi; oldPhi(aIndex(j),:)];
		newPsi = [newPsi; oldPsi(aIndex(j),:)];
		newPhiStr = [newPhiStr; oldPhiStr(aIndex(j),:)];
		newPsiStr = [newPsiStr; oldPsiStr(aIndex(j),:)];
		newTable = [newTable; oldTable(aIndex(j),:)];
	end

	startIndex = size(newPsi,1) + 1;

	% Get the new data
	[newXx, newZU, newZL, newF, phiAF, psiAF, phiStrAF, psiStrAF, newElementCounter, airfoilTable, cL, lednicer] = generateAirfoil(hObject,handles,startIndex);

	% And write it into the arrays
	newPhi = [newPhi;phiAF];
	newPsi = [newPsi;psiAF];
	newPhiStr = [newPhiStr;phiStrAF];
	newPsiStr = [newPsiStr;psiStrAF];
	newTable = [newTable;airfoilTable];
function [xx, zU, zL, f, phi, psi, phiStr, psiStr, elementCounter, airfoilTable, cL, lednicer] = generateAirfoil(hObject,handles,startIndex)

	% -------------------------------------------------------------------------	%
	% Generate airfoil data (cord xx, upper and lower surface zU/zL, mean 		%
	% camber camber line f) and update velocity potential and stream function 	%
	% according to that data. 													%
	%																			%
	% Output 																	%
	% xx...		[1xm num]	Values along cord between 0 and 1 					%
	% zU...		[1xm num]	Values of upper airfoil surface corresponding to xx %
	% zL...		[1xm num]	Values of lower airfoil surface corresponding to xx %
	% f...		[1xm num]	Values of mean camber line corresponding to xx 		%
	% phi...	[nx2 sym]	Symbolical function vector of all velocity potential%
	% psi...	[nx2 sym] 	Symbolical function vector of all stream functions	%
	% phiStr...	[nx2 cell]	Array of all velocity potential as LaTeX strings	%
	% psiStr...	[nx2 cell] 	Array of all stream functions as LaTeX strings		%
	% airfoilTable...[nx6 cell] 	Table entries of the singularities 			%
	% cL...		[1x1 num]	Lift coefficient 									% 	
	% lednicer..[1x1 num]	format of airfoil data. 1 = lednicer, 0 = selig		%
	% ------------------------------------------------------------------------- %

	if isempty(handles.airfoilData) == false
		
		% Get the geometry of the airfoil
		[xx, theta, mcl, zU, zL, f, lednicer] = getAirfoil(handles.airfoilData);
		% Get U inf and alpha
		[uInf, alpha] = getUInfAlpha(hObject,handles);

		% Calculate additional camber line and angle according to Truckenbrodt.
		% This ensures that the airfoils thickness is taken into account for
		% different angles of attack.
		dfdtheta = (f(2)-0)/(theta(2)-pi);
		deltaF = alpha.*( sqrt((1-xx)./(xx)).*f + 2.*(1-xx).*dfdtheta );
		deltaAlpha = -2*alpha*dfdtheta;
 
 		% Since deltaF(1) is always NaN, start with deltaF(2)
		f(2:end) = f(2:end) + deltaF(2:end);
		alphaCalc = alpha + deltaAlpha;

		% Calculate vortex and source distribution for theairfoil
		[gamma, cL] = vortexDistribution(xx,theta,mcl,uInf,alphaCalc,alpha,handles.meshsize);
		q = sourceDistribution(xx,f,uInf);

		% Reduce size of vortex and source distribution, so there is one vortex
		% and one source/sink on every meshpoint of the cord.
		N = 1/handles.meshsize;
		gammac = compress(gamma,N);
		qc = compress(q,N);
		% Generate vector of x values of the cord.
		xxc = 0:1/(N):1;

		elementCounter = startIndex;

		% Initialize new velocity potential vector and stream function vector
		% for airfoil. They will later be attached to the previous arrays
		phi = sym(@(x,y) zeros(0,2));
		psi = sym(@(x,y) zeros(0,2));
		phiStr = cell(0,3);
		psiStr = cell(0,3);

		% Initialize symbolic variables
		syms x y
		% Initialize the table containing the singularities
		airfoilTable = num2cell(zeros(2*max(size(gammac)),6));

		for i = 1:max(size(gammac))

			strength_wish_vortex = gammac(i);
			strength_wish_source = qc(i);
			posX_wish = xxc(i);

			% Add new velocity potential and stream function of current vortex
			% to corresponding arrays
			[phiTemp,psiTemp,phiStrTemp,psiStrTemp] = genPot('vortex',strength_wish_vortex,posX_wish,0,x,y);

			phi = [phi;elementCounter, phiTemp, 'A'];
			psi = [psi;elementCounter, psiTemp, 'A'];
			phiStr = [phiStr;{elementCounter, phiStrTemp, 'A'}];
			psiStr = [psiStr;{elementCounter, psiStrTemp, 'A'}];
			
			% Gather content of new vortex row for table
			airfoilTable(-1+2*i,:) = {elementCounter,'Vortex', strength_wish_vortex, posX_wish, 0, [] };

			elementCounter = elementCounter + 1;

			% Add new velocity potential and stream function of current source
			% to corresponding arrays
			[phiTemp,psiTemp,phiStrTemp,psiStrTemp] = genPot('source',strength_wish_source,posX_wish,0,x,y);
			phi = [phi;elementCounter, phiTemp, 'A'];
			psi = [psi;elementCounter, psiTemp, 'A'];
			phiStr = [phiStr;{elementCounter, phiStrTemp, 'A'}];
			psiStr = [psiStr;{elementCounter, psiStrTemp, 'A'}];

			% Gather content of new source row for table
			airfoilTable(2*i,:) = {elementCounter,'Source/Sink', strength_wish_source, posX_wish, 0, [] };

			elementCounter = elementCounter + 1;

		end		
		elementCounter = elementCounter - 1;
	end
function [uInf, alpha] = getUInfAlpha(hObject, handles)
	% ------------------------------------------------------------------------- %
	% Get uInf and alpha as superposition of all current freestreams 			%
	% ------------------------------------------------------------------------- %

	% Get data from table
	data = get(handles.uitable1,'data');

	% Initialize U inf and alpha
	uInfVec = [];
	alpha = 0;

	% Superponate the velocity vectors of every freestream
	for i = 1:size(data,1)
		if strcmp(data(i,2),'Freestream') == true
			uInfVec = [uInfVec;data{i,3}*round(cos(data{i,6}),15),data{i,3}*round(sin(data{i,6}),15)];
		end
	end
	% uInf is the superposition of all freestreams and alpha is the angle
	% between the effective direction of uInf and the airfoil's cord.
	uInfVec = sum(uInfVec,1);
	uInf = norm(uInfVec,2);
	alpha = atan2(uInfVec(2),uInfVec(1));
function [xx, theta, mcl, zU, zL, f, lednicer] = getAirfoil(AF)

	% -------------------------------------------------------------------------	%
	% Generate airfoil data with many interpolated points from standart .dat 	%
	% file (selig format)														%
	% 																			%
	% Input																		%
	% AF...       [nx1 num]   Discrete contour of airfoil, starting and 		%
	% 						  closing at trailing edge  						%
	%																			%
	% Output																	%
	% x...		[mx1 num]	even spaced x values 								%
	% theta...	[mx1 num]	corresponding theta values							%
	% mcl...	[mx1 num]	mean camber line 									%
	% zU...		[mx1 num]	upper airfoil surface 								%
	% zL...		[mx1 num]	lower airfoil surface 								%
	% f...		[mx1 num]	surface of symmetric airfoil with equal thickness 	%
	%						distribution										%
	% lednicer..[1x1 num]	format of airfoil data. 1 = lednicer, 0 = selig		%
	% -------------------------------------------------------------------------	%

	% Create linear interpolation of airfoil, so x values of bottom and top
	% correlate

	% For a accurate cosine approximation, a stepsize of 1/1000 has proven to be
	% sufficient
	h = 0.001;
	% Generate xx values with stepsize h
	xx = transpose(0:h:1);

	% If the airfoil data is in Lednicer format, the first row contains how many
	% points there are. Ignore that information.
	lednicer = 0;
	if AF(1,1) >= 2
		lednicer = 1;
		AF(1,:) = [];
	end

	% Split airfoil data AF into upper ([xU yU]) and lower ([xL yL]) surface

	if lednicer == 0
		minAF = min(AF(:,1));
		for i = 1:size(AF,1)
		    if AF(i,1) == minAF
		        SU = [flip(AF(1:i,:))];
		        xU = SU(:,1);
		        yU = SU(:,2);
		        SL = [AF(i:end,:)];
		        xL = SL(:,1);
		        yL = SL(:,2);
		        break
		    end
		end
	else
		minAF = min(AF(2:end,1));
		for i = 2:size(AF,1)
		    if AF(i,1) == minAF
		        SU = [AF(1:i,:)];
		        xU = SU(:,1);
		        yU = SU(:,2);
		        SL = [AF(i:end,:)];
		        xL = SL(:,1);
		        yL = SL(:,2);
		        break
		    end
		end
	end


	% Clean up upper and lower surface data
	if xU(1) ~= 0; xU(1) = 0; yU(1) = 0; end
	if xL(1) ~= 0; xL(1) = 0; yL(1) = 0; end
	if yL(2,1) >= 0; yL(2,:) = []; xL(2,:) = []; end
	if yU(2,1) <= 0; yU(2,:) = []; xU(2,:) = []; end
	if xU(end) == 0; xU(end) = []; yU(end) = []; end
	if xL(end) == 0; xL(end) = []; yL(end) = []; end

	% Interpolate upper and lower surface at xx values
	zU = interp1(xU,yU,xx);
	zL = interp1(xL,yL,xx);

	% Calculate mean chamber line and symmetric airfoil with equal thickness
	% distribution
	mcl = (zU+zL)./2;
	f = zU - mcl;

	% Calculate angle theta measured from [c/2 0]
	theta = acos(2.*xx-1);
function [kComp] = compress(k,N)

	% -------------------------------------------------------------------------	%
	% Compress k in N blocks with g entries, so k and kComp have the same sum. 	%
	%																			%
	% Input 																	%
	% k...	[mx1 num]	vector to be compressed									%
	% N...	[1x1 num]	number of blocks										%
	% t...  [string]	compression type (same sum/same amplitude)				%
	%																			%
	% Output 																	%
	% kComp	[nx1 num]	compressed vector 										%
	% -------------------------------------------------------------------------	%

	% Only round values are accepted
	N = round(N);
	% Calculate the number of element to compress into one new element
	g = max(size(k))/N;

	% If there should be less than one element in one new element, don't
	% compress at all.
	if g > 1
		for i=1:(N)
			bIndex = round((i-1)*g + 1);
			eIndex = round((i-1)*g + g);
			kComp(i) = sum(k(bIndex:eIndex));
		end
	else
		kComp = k;
	end
function [q] = sourceDistribution(xx,f,uInf)

	% -------------------------------------------------------------------------	%
	% The distribution of sources for a tear drop airfoil with the surface f is %
	% calculated with the equation q(x) = 2 U_inf dfdx. 						%
	%																			%
	%																			%
	% Input:																	%
	% xx...		(1xm num) values of x 	 										%
	% f...		(1xm num) values of f(x), the airfoil contour					%
	% uInf...	(1x1 num) velocity of incoming flow								%
	%																			%
	%																			%
	% Output:																	%
	% q...		(1xm num) source distribution (teardrop theory)	 				%
	% ------------------------------------------------------------------------- %

	% Numerical derivative calculated with forward difference quotient
	dfdx = zeros(max(size(f)),1);
	for i = 1:(max(size(f))-1)
		dfdx(i) = (f(i+1) - f(i))/((xx(i+1)-xx(i)));
	end

	% The sum of all sources and sinks has to equal zero, so the flow neither
	% leaps out of the airfoil nor into it. This is just to avoid errors due to
	% numerical errors, so usually the negative sum is around zero
	dfdx(end) = -sum(dfdx);

	% Calculate the source distribtion
	% q(x) = 2 U_inf dfdx
	q = 2.*uInf.*dfdx;

	% Normalize q
	q = q./max(size(xx));
	q = q./(pi/4);
function [gamma,cL] = vortexDistribution(xx,theta,z,uInf,alphaCalc,alpha,meshsize)

	% -------------------------------------------------------------------------	%
	% This function approximates the mean chamber line z(theta) with cosine		%
	% series expansion z(theta) = 0.5*sum(an*cos(theta)). The coefficents a_n 	%
	% are calculated with numerical integration of the cosine fourier 			%
	% integrals. With the approximated airfoil, the vortex distribution is 		%
	% calculated as proposed by H. Schlichting and E. Truckenbrodt in 			%
	% "Aerodynamik des Flugzeuges, Erster Band" in equation [6.112]. The 		%
	% vortex distribution is then bounded to cut the diverging parts and 		%
	% normalized 																%
	%																			%
	%																			%
	% Input:																	%
	% theta...	(1xm num) values of theta 										%
	% z...		(1xm num) values of z(theta) 									%
	%																			%
	% Theta and z are given as discrete values. Many (>10e3) points are needed 	%
	% for accurate approximation.												%
	%																			%
	% Output:																	%
	% gamma...	(1xm num) vortex distribution (thin airfoil theory)	 			%
	% ------------------------------------------------------------------------- %

	N = 20;

	% Prealocate vector a for speed and write a0
	a = zeros(N,1);

	for n=1:N
		% Calculate the nth coefficient a_n
		intZn = 0;
		for i=1:(size(theta,1)-1)
			intZn = intZn - (theta(i+1)-theta(i))*(z(i+1)*cos(n*theta(i+1))+z(i)*cos(n*theta(i)))/2;
		end
		% Write value to a vector
		a(n) = 4/pi*intZn;
	end

	% Calculate sum_(n=1)^N n * a_n * ( cos( n*theta ) - 1 )/sin( n*theta )  [6.112]
	sumK = 0;
	for n = 1:(N)
		sumK = sumK + n .* a(n) .* (cos( n.*theta ) - 1)./(sin( theta ));
	end

	% Take the coordinate transformation into account
	sumK = sumK./(pi/4);

	% Calculate gamma
	gamma = 2.*uInf.*(alphaCalc.*tan(theta./2) + sumK );

	% gamma diverges for x -> 0, therefore the values of k have to be bounded to
	% a certain threshold. Its value is arbitrary, 10 times gamma(6) was
	% empirical obtained because the results were good. A more complex
	% adaptation could give better results, though.
	gamma(1) = 10*gamma(6);

	% The last value of k is NaN (not a number). Because of kutta's trailing
	% edge condition  the last vortex has to be zero.
	gamma(end) = 0;

	% Normalize gamma. Normalization is necessary, because sum(gamma) has to
	% equal int_0^1 gamma dx, so the total vorticity of the airfoil is the same.
	gamma = gamma.*max(diff(xx));

	% Calculate cL = int 2/uInf gamma dx
	cL = 2/uInf*trapz(gamma);

	% A vortex with a positive vorticity should be mathematically positive
	% orientated, therefore the sign has to be flipped
	gamma = -gamma;
% ............................ UI Elements Callback ............................

function okbutton_Callback(hObject, eventdata, handles)
	% Get selection from popupmenu
	set(handles.warningText,'String','')
	St=get(handles.elementMenu,'String');

	% Get values from textfields
	popup_sel_index = get(handles.elementMenu,'Value');
	strength_wish = get(handles.strengthEdit,'String');
	posX_wish = get(handles.posXEdit,'String');
	posY_wish = get(handles.posYEdit,'String');

	% If boxes are left empty, set value to default value
	if isempty(strength_wish) == true;
		strength_wish = '1';
	end
	if isempty(posX_wish) == true;
		posX_wish = '0';
	end
	if isempty(posY_wish) == true && popup_sel_index ~= 1;
		posY_wish = '0';
	end


	% Initiate symbolic variables
	syms x y

	handles.elementCounter = handles.elementCounter + 1;
	% Get content of table
	oldData = get(handles.uitable1,'data');
	% Check which element type is selected
	switch popup_sel_index
		case 1 % Freestream
			% Add new velocity potential and stream function to corresponding arrays
			[phi,psi,phiStr,psiStr] = genPot('freestream',str2num(strength_wish),str2num(posX_wish),x,y);
			% Gather content of new row for table
			newRow = {handles.elementCounter,'Freestream', str2num(strength_wish), [], [], str2num(posX_wish)};
		case 2 % Source/Sink
			% Add new velocity potential and stream function to corresponding arrays
			[phi,psi,phiStr,psiStr] = genPot('source',str2num(strength_wish),str2num(posX_wish),str2num(posY_wish),x,y);
			% Gather content of new row for table
			newRow = {handles.elementCounter,'Source/Sink', str2num(strength_wish), str2num(posX_wish), str2num(posY_wish), [] };
		case 3 % Doublet
			% Add new velocity potential and stream function to corresponding arrays
			[phi,psi,phiStr,psiStr] = genPot('doublet',str2num(strength_wish),str2num(posX_wish),str2num(posY_wish),x,y);
			% Gather content of new row for table
			newRow = {handles.elementCounter,'Doublet', str2num(strength_wish), str2num(posX_wish), str2num(posY_wish), [] };
		case 4 % Vortex
			% Add new velocity potential and stream function to corresponding arrays
			[phi,psi,phiStr,psiStr] = genPot('vortex',str2num(strength_wish),str2num(posX_wish),str2num(posY_wish),x,y);
			% Gather content of new row for table
			newRow = {handles.elementCounter,'Vortex', str2num(strength_wish), str2num(posX_wish), str2num(posY_wish), [] };
	end
	% Update table content
	newData = [oldData; newRow];
	set(handles.uitable1,'data',newData);

	% Update velocity potential and stream function arrays
	handles.phi = [handles.phi;handles.elementCounter, phi, 'N'];
	handles.psi = [handles.psi;handles.elementCounter, psi, 'N'];
	handles.phiStr = [handles.phiStr;{handles.elementCounter, phiStr, 'N'}];
	handles.psiStr = [handles.psiStr;{handles.elementCounter, psiStr, 'N'}];

	% Plot updated systemd
	[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject, handles);

	figure1_SizeChangedFcn(hObject, [], handles)
	% Update handles structure
	guidata(hObject, handles);
function elementMenu_Callback(hObject, eventdata, handles)
	set(handles.warningText,'String','')
	% Set the visibility of input boxes and labels corresponding
	% to selected element type.

	% Get selected element type
	popup_sel_index = get(hObject,'Value');
	% Set visibility
	switch popup_sel_index
		case 1 % Freestream
			set(handles.posXText,'String','Angle')
			set(handles.posYText,'visible','off')
			set(handles.posYEdit,'visible','off')
		otherwise % Sink/Source, Doublet or Vortex
			set(handles.posXText,'String','X Pos')
			set(handles.posYText,'visible','on')
			set(handles.posYEdit,'visible','on')
			set(handles.posYText,'String','Y Pos')
	end
	guidata(hObject, handles);
function settingsButton_Callback(hObject, eventdata, handles)
	set(handles.warningText,'String','')
	% Show/hide settings

	axesVis = get(handles.axes1,'visible');
	if strcmp(axesVis,'off') == true
		set(handles.axes1,'visible','on')
		set(handles.slaImage,'visible','off')

		set(handles.textMeshsize,'visible','off')
		set(handles.textSLDY,'visible','off')
		set(handles.textBeta1,'visible','off')
		set(handles.textBeta2,'visible','off')
		set(handles.textMaxX,'visible','off')
		set(handles.textMinX,'visible','off')
		set(handles.textMaxY,'visible','off')
		set(handles.textMinY,'visible','off')

		set(handles.editMeshsize,'visible','off')
		set(handles.editSLDY,'visible','off')
		set(handles.editBeta1,'visible','off')
		set(handles.editBeta2,'visible','off')
		set(handles.editMaxX,'visible','off')
		set(handles.editMinX,'visible','off')
		set(handles.editMaxY,'visible','off')
		set(handles.editMinY,'visible','off')

		set(handles.streamCheck,'visible','off')
		set(handles.potCheck,'visible','off')
		set(handles.pressCheck,'visible','off')
		set(handles.vecCheck,'visible','off')
		set(handles.altViewCheck,'visible','off')
		set(handles.symbCheck,'visible','off')
		set(handles.cpPlotCheck,'visible','off')
		set(handles.xFoilCheck,'visible','off')
		set(handles.aniCheck,'visible','off')
		set(handles.scaleCheck,'visible','off')
		set(handles.equalCheck,'visible','off')

		set(handles.yMaxPlusButton,'visible','on')
		set(handles.yMaxMinusButton,'visible','on')
		set(handles.yMinPlusButton,'visible','on')
		set(handles.yMinMinusButton,'visible','on')
		set(handles.xMaxPlusButton,'visible','on')
		set(handles.xMaxMinusButton,'visible','on')
		set(handles.xMinPlusButton,'visible','on')
		set(handles.xMinMinusButton,'visible','on')
		set(handles.yPanel,'visible','on')
		set(handles.yText,'visible','on')
		set(handles.xPanel,'visible','on')
		set(handles.xText,'visible','on')

		set(handles.yMaxPlusButton,'Enable','on')
		set(handles.yMaxMinusButton,'Enable','on')
		set(handles.yMinPlusButton,'Enable','on')
		set(handles.yMinMinusButton,'Enable','on')
		set(handles.xMaxPlusButton,'Enable','on')
		set(handles.xMaxMinusButton,'Enable','on')
		set(handles.xMinPlusButton,'Enable','on')
		set(handles.xMinMinusButton,'Enable','on')

		set(handles.okbutton,'Enable','on')
		set(handles.airFoilLoadButton,'Enable','on')
		set(handles.resetButton,'Enable','on')
		set(handles.expPotButton,'Enable','on')
		set(handles.expDatButton,'Enable','on')
		set(handles.expFigButton,'Enable','on')

		set(handles.redrawButton,'visible','on')

		set(handles.particleButton,'Enable','on');

		if handles.colorbarVisible == 1;
			colorbar('peer',handles.axes1);
		end

		if isempty(handles.airfoilData) == false && handles.airfoilUpdateNecessary == true
			[handles.phi, handles.psi, handles.phiStr, handles.psiStr, newData, handles.xx, handles.zU, handles.zL, handles.f, handles.elementCounter, handles.cL] = updateAirfoil(hObject,handles);
			handles.airfoilUpdateNecessary = 0;
			set(handles.uitable1,'data',newData);
		end
		if isempty(handles.cL) == false
			% Show cL value
			set(handles.cLText,'String',sprintf('cL = %2f',handles.cL))
		end

		[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
		figure1_SizeChangedFcn(hObject, [], handles)

	else
		cla(handles.axes1);
		cla(handles.cpAxes);
		set(handles.axes1,'visible','off')
		set(handles.cpAxes,'visible','off')
		legend(handles.cpAxes,'off');
		set(handles.slaImage,'visible','on')

		set(handles.textMeshsize,'visible','on')
		set(handles.textSLDY,'visible','on')
		set(handles.textBeta1,'visible','on')
		set(handles.textBeta2,'visible','on')
		set(handles.textMaxX,'visible','on')
		set(handles.textMinX,'visible','on')
		set(handles.textMaxY,'visible','on')
		set(handles.textMinY,'visible','on')

		set(handles.editMeshsize,'visible','on')
		set(handles.editSLDY,'visible','on')
		set(handles.editBeta1,'visible','on')
		set(handles.editBeta2,'visible','on')
		set(handles.editMaxX,'visible','on')
		set(handles.editMinX,'visible','on')
		set(handles.editMaxY,'visible','on')
		set(handles.editMinY,'visible','on')

		set(handles.streamCheck,'visible','on')
		set(handles.potCheck,'visible','on')
		set(handles.pressCheck,'visible','on')
		set(handles.vecCheck,'visible','on')
		set(handles.altViewCheck,'visible','on')
		set(handles.symbCheck,'visible','on')
		set(handles.cpPlotCheck,'visible','on')
		set(handles.aniCheck,'visible','on')
		set(handles.scaleCheck,'visible','on')
		set(handles.equalCheck,'visible','on')


		compOS = computer;
		% compOS = 'PCWIN64'
		if strcmp(compOS,'PCWIN64') == true || strcmp(compOS,'PCWIN') == true
			set(handles.xFoilCheck,'visible','on')
		end

		set(handles.yMaxPlusButton,'visible','off')
		set(handles.yMaxMinusButton,'visible','off')
		set(handles.yMinPlusButton,'visible','off')
		set(handles.yMinMinusButton,'visible','off')
		set(handles.xMaxPlusButton,'visible','off')
		set(handles.xMaxMinusButton,'visible','off')
		set(handles.xMinPlusButton,'visible','off')
		set(handles.xMinMinusButton,'visible','off')
		set(handles.yPanel,'visible','off')
		set(handles.yText,'visible','off')
		set(handles.xPanel,'visible','off')
		set(handles.xText,'visible','off')

		set(handles.yMaxPlusButton,'Enable','off')
		set(handles.yMaxMinusButton,'Enable','off')
		set(handles.yMinPlusButton,'Enable','off')
		set(handles.yMinMinusButton,'Enable','off')
		set(handles.xMaxPlusButton,'Enable','off')
		set(handles.xMaxMinusButton,'Enable','off')
		set(handles.xMinPlusButton,'Enable','off')
		set(handles.xMinMinusButton,'Enable','off')

		set(handles.okbutton,'Enable','off')
		set(handles.airFoilLoadButton,'Enable','off')
		set(handles.resetButton,'Enable','off')
		set(handles.expPotButton,'Enable','off')
		set(handles.expDatButton,'Enable','off')
		set(handles.expFigButton,'Enable','off')

		set(handles.redrawButton,'visible','off')

		if handles.colorbarVisible == 1;
			colorbar(handles.axes1,'off');
		end

		if isempty(handles.cL) == false
			% Show cL value
			set(handles.cLText,'String',sprintf('',handles.cL))
		end

		figure1_SizeChangedFcn(hObject, [], handles)
	end
	guidata(hObject,handles)
function uitable1_CellEditCallback(hObject, eventdata, handles)
	set(handles.warningText,'String','')
	% Get indices of changed cell
	r = eventdata.Indices(1);
	c = eventdata.Indices(2);
	editNr = hObject.Data{r,1};

	syms x y

	% Find out what has changed
	handles.elementCounter = handles.elementCounter + 1;
	switch c
		case 2 % Type changed
			% Get edited Data
			editData = eventdata.EditData; % char
			% Check which type is chosen
			switch editData
				case 'Freestream'
					% Read strength from table
					strength_wish = hObject.Data{r,3};
					% Check whether angle cell is empty
					if isempty(hObject.Data{r,6}) == true 	
						posX_wish = 0;
						% If so, set the desired angle to 0
	 					set(hObject.Data{r,6},posX_wish); 	
	 				else
	 					% If it's not, read the cell content
	 					posX_wish = hObject.Data{r,6};		
					end

					% Update velocity potential and stream function
					[phi,psi,phiStr,psiStr] = genPot('freestream',strength_wish,posX_wish,x,y);
					newRow = {handles.elementCounter,'Freestream', strength_wish, [], [], posX_wish };
				
				case 'Source/Sink'
					% Read strength from table
					strength_wish = hObject.Data{r,3};
					% Check whether pos x cell is empty
					if isempty(hObject.Data{r,4}) == true 
						posX_wish = 0;
						% If so, set the desired position to 0
	 					set(hObject.Data{r,4},posX_wish); 
	 				else
	 					% If it's not, read the cell content
	 					posX_wish = hObject.Data{r,4};		
					end
					% Check whether pos y cell is empty
					if isempty(hObject.Data{r,5}) == true 
						posY_wish = 0;
						% If so, set the desired position to 0
	 					set(hObject.Data{r,5},posY_wish); 
	 				else
	 					% If it's not, read the cell content
	 					posY_wish = hObject.Data{r,5};		
					end

					% Update velocity potential and stream function
					[phi,psi,phiStr,psiStr] = genPot('source',strength_wish,posX_wish,posY_wish,x,y);
					newRow = {handles.elementCounter,'Source/Sink', strength_wish, posX_wish, posY_wish, [] };
				
				case 'Doublet'
					% Read strength from table
					strength_wish = hObject.Data{r,3};
					% Check whether pos x cell is empty
					if isempty(hObject.Data{r,4}) == true 	
						posX_wish = 0;
						% If so, set the desired position to 0
	 					set(hObject.Data{r,4},posX_wish); 	
	 				else
	 					% If it's not, read the cell content
	 					posX_wish = hObject.Data{r,4};		
					end
					% Check whether pos y cell is empty
					if isempty(hObject.Data{r,5}) == true 	
						posY_wish = 0;
						% If so, set the desired position to 0
	 					set(hObject.Data{r,5},posY_wish); 	
	 				else
	 					% If it's not, read the cell content
	 					posY_wish = hObject.Data{r,5};		
					end
					% Update velocity potential and stream function
					[phi,psi,phiStr,psiStr] = genPot('doublet',strength_wish,posX_wish,posY_wish,x,y);
					newRow = {handles.elementCounter,'Doublet', strength_wish, posX_wish, posY_wish, [] };
				
				case 'Vortex'
					% Read strength from table
					strength_wish = hObject.Data{r,3};
					% Check whether pos x cell is empty
					if isempty(hObject.Data{r,4}) == true 	
						posX_wish = 0;
						% If so, set the desired position to 0
	 					set(hObject.Data{r,4},posX_wish); 	
	 				else
	 					% If it's not, read the cell content
	 					posX_wish = hObject.Data{r,4};		
					end
					% Check whether pos y cell is empty
					if isempty(hObject.Data{r,5}) == true 	
						posY_wish = 0;
						% If so, set the desired position to 0
	 					set(hObject.Data{r,5},posY_wish); 	
	 				else
	 					% If it's not, read the cell content
	 					posY_wish = hObject.Data{r,5};		
					end
					% Update velocity potential and stream function
					[phi,psi,phiStr,psiStr] = genPot('vortex',strength_wish,posX_wish,posY_wish,x,y);
					newRow = {handles.elementCounter,'Vortex', strength_wish, posX_wish, posY_wish, [] };
			end

			% Update table
			% Get old data from table
			oldData = get(handles.uitable1,'data');	
			% Remove previous line
			oldData(r,:) = [];						
			% Add new line
			newData = [oldData; newRow];			
			% Find free Number
			sizeNewData = size(newData);			
			% Assign free number
			newData{sizeNewData(1),1} = r;			
			% Sort rows
			newData = sortrows(newData,1);			
			% Write changes to table
			set(handles.uitable1,'data',newData);	

			% Update psi and phi
	 		% Remove previous line
			handles.phi(r,:) =[];
			handles.psi(r,:) =[];
			handles.phiStr(r,:) =[];
			handles.psiStr(r,:) =[];
			% Add changed line and assign number of removed line
	 		handles.phi = [handles.phi;r, phi, 'N'];
			handles.psi = [handles.psi;r, psi, 'N'];
	 		handles.phiStr = [handles.phiStr;{r, phiStr, 'N'}];
			handles.psiStr = [handles.psiStr;{r, psiStr, 'N'}];
	 		% Sort array
			handles.phi = sortrows(handles.phi,1);
			handles.psi = sortrows(handles.psi,1);
			handles.phiStr = sortrows(handles.phiStr,1);
			handles.psiStr = sortrows(handles.psiStr,1);

		case 3 % Strength changed
			% Get new value
			strength_wish = eval(eventdata.EditData); % num
			% Check if desired strength is zero
			if strength_wish ~= 0
				editType = hObject.Data{r,2};
				% Get new velocity potential and stream function according to element type
				switch editType
					case 'Freestream'
						posX_wish = hObject.Data{r,6};
						[phi,psi,phiStr,psiStr] = genPot('freestream',strength_wish,posX_wish,x,y);
					case 'Source/Sink'
						posX_wish = hObject.Data{r,4};
						posY_wish = hObject.Data{r,5};
						[phi,psi,phiStr,psiStr] = genPot('source',strength_wish,posX_wish,posY_wish,x,y);
					case 'Doublet'
						posX_wish = hObject.Data{r,4};
						posY_wish = hObject.Data{r,5};
						[phi,psi,phiStr,psiStr] = genPot('doublet',strength_wish,posX_wish,posY_wish,x,y);
					case 'Vortex'
						posX_wish = hObject.Data{r,4};
						posY_wish = hObject.Data{r,5};
						[phi,psi,phiStr,psiStr] = genPot('vortex',strength_wish,posX_wish,posY_wish,x,y);
				end

				% Update psi and phi
			 	% Remove previous line
				handles.phi(r,:) =[];
				handles.psi(r,:) =[];
				handles.phiStr(r,:) =[];
				handles.psiStr(r,:) =[];
				% Add changed line and assign number of removed line
		 		handles.phi = [handles.phi;r, phi, 'N'];
				handles.psi = [handles.psi;r, psi, 'N'];
		 		handles.phiStr = [handles.phiStr;{r, phiStr, 'N'}];
				handles.psiStr = [handles.psiStr;{r, psiStr, 'N'}];
		 		% Sort array
				handles.phi = sortrows(handles.phi,1);
				handles.psi = sortrows(handles.psi,1);
				handles.phiStr = sortrows(handles.phiStr,1);
				handles.psiStr = sortrows(handles.psiStr,1);
			else % If strength equals zero, delete the element
				handles.phi(r,:) =[];
				handles.psi(r,:) =[];
				handles.phiStr(r,:) =[];
				handles.psiStr(r,:) =[];
				phiSize = size(handles.phi);
				for i=r:phiSize(1)
					handles.phi(i,1) = [i];
					handles.psi(i,1) = [i];
					handles.phiStr{i,1} = [i];
					handles.psiStr{i,1} = [i];
				end

				% Get old data from table
				oldData = get(handles.uitable1,'data');	
				% Remove previous line
				oldData(r,:) = [];						
				oldDataSize = size(oldData);
				for i=r:oldDataSize(1)
					oldData{i,1} = i;
				end
				% Write changes to table
				set(handles.uitable1,'data',oldData);	
			end

		case 4 % Pos X changed
			update = 0;
			posX_wish = eval(eventdata.EditData); % num
			editType = hObject.Data{r,2};
			switch editType
				case 'Freestream'
					% Get data from table
					oldData = get(handles.uitable1,'data');	
					% Remove false entry
					oldData{r,c} = [];						
					% Write changes to table
					set(handles.uitable1,'data',oldData);	
				case 'Source/Sink'
					strength_wish = hObject.Data{r,3};
					posY_wish = hObject.Data{r,5};
					[phi,psi,phiStr,psiStr] = genPot('source',strength_wish,posX_wish,posY_wish,x,y);
					update = 1;
				case 'Doublet'
					strength_wish = hObject.Data{r,3};
					posY_wish = hObject.Data{r,5};
					[phi,psi,phiStr,psiStr] = genPot('doublet',strength_wish,posX_wish,posY_wish,x,y);
					update = 1;
				case 'Vortex'
					strength_wish = hObject.Data{r,3};
					posY_wish = hObject.Data{r,5};
					[phi,psi,phiStr,psiStr] = genPot('vortex',strength_wish,posX_wish,posY_wish,x,y);
					update = 1;
			end

			if update == 1
				% Update psi and phi
			 	% Remove previous line
				handles.phi(r,:) =[];
				handles.psi(r,:) =[];
				handles.phiStr(r,:) =[];
				handles.psiStr(r,:) =[];
				% Add changed line and assign number of removed line
		 		handles.phi = [handles.phi;r, phi, 'N'];
				handles.psi = [handles.psi;r, psi, 'N'];
		 		handles.phiStr = [handles.phiStr;{r, phiStr, 'N'}];
				handles.psiStr = [handles.psiStr;{r, psiStr, 'N'}];
		 		% Sort array
				handles.phi = sortrows(handles.phi,1);
				handles.psi = sortrows(handles.psi,1);
				handles.phiStr = sortrows(handles.phiStr,1);
				handles.psiStr = sortrows(handles.psiStr,1);
			end

		case 5 % Pos Y changed
			update = 0;
			posY_wish = eval(eventdata.EditData); % num
			editType = hObject.Data{r,2};
			switch editType
				case 'Freestream'
					% Get data from table
					oldData = get(handles.uitable1,'data');	
					% Remove false entry
					oldData{r,c} = [];						
					% Write changes to table
					set(handles.uitable1,'data',oldData);	
				case 'Source/Sink'
					strength_wish = hObject.Data{r,3};
					posX_wish = hObject.Data{r,4};
					[phi,psi,phiStr,psiStr] = genPot('source',strength_wish,posX_wish,posY_wish,x,y);
					update = 1;
				case 'Doublet'
					strength_wish = hObject.Data{r,3};
					posX_wish = hObject.Data{r,4};
					[phi,psi,phiStr,psiStr] = genPot('doublet',strength_wish,posX_wish,posY_wish,x,y);
					update = 1;
				case 'Vortex'
					strength_wish = hObject.Data{r,3};
					posX_wish = hObject.Data{r,4};
					[phi,psi,phiStr,psiStr] = genPot('vortex',strength_wish,posX_wish,posY_wish,x,y);
					update = 1;
			end
			
			if update == 1
				% Update psi and phi
			 	% Remove previous line
				handles.phi(r,:) =[];
				handles.psi(r,:) =[];
				handles.phiStr(r,:) =[];
				handles.psiStr(r,:) =[];
				% Add changed line and assign number of removed line
		 		handles.phi = [handles.phi;r, phi, 'N'];
				handles.psi = [handles.psi;r, psi, 'N'];
		 		handles.phiStr = [handles.phiStr;{r, phiStr, 'N'}];
				handles.psiStr = [handles.psiStr;{r, psiStr, 'N'}];
		 		% Sort array
				handles.phi = sortrows(handles.phi,1);
				handles.psi = sortrows(handles.psi,1);
				handles.phiStr = sortrows(handles.phiStr,1);
				handles.psiStr = sortrows(handles.psiStr,1);
			end

		case 6 % Angle changed
			angle_wish = eval(eventdata.EditData); % num
			editType = hObject.Data{r,2};
			switch editType
				case 'Freestream'
					strength_wish = hObject.Data{r,3};
					[phi,psi,phiStr,psiStr] = genPot('freestream',strength_wish,angle_wish,x,y);

					% Update psi and phi
				 	% Remove previous line
					handles.phi(r,:) =[];
					handles.psi(r,:) =[];
					handles.phiStr(r,:) =[];
					handles.psiStr(r,:) =[];
					% Add changed line and assign number of removed line
			 		handles.phi = [handles.phi;r, phi, 'N'];
					handles.psi = [handles.psi;r, psi, 'N'];
			 		handles.phiStr = [handles.phiStr;{r, phiStr, 'N'}];
					handles.psiStr = [handles.psiStr;{r, psiStr, 'N'}];
			 		% Sort array
					handles.phi = sortrows(handles.phi,1);
					handles.psi = sortrows(handles.psi,1);
					handles.phiStr = sortrows(handles.phiStr,1);
					handles.psiStr = sortrows(handles.psiStr,1);

					% Get data from table
					oldData = get(handles.uitable1,'data');	
					% Update angle to avoid NaN
					oldData{r,c} = [angle_wish];			
					% Write changes to table
					set(handles.uitable1,'data',oldData);	
				otherwise
					% Get data from table
					oldData = get(handles.uitable1,'data');	
					% Remove false entry
					oldData{r,c} = [];						
					% Write changes to table
					set(handles.uitable1,'data',oldData);	
			end
	end
	handles.elementCounter = handles.elementCounter - 1;

	[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);

	if isempty(handles.airfoilData) == false
		updateAirfoil(hObject, handles);
	end

	guidata(hObject, handles);
function resetButton_Callback(hObject, eventdata, handles)
	% Reset everything but the settings
	set(handles.warningText,'String','')
	handles.airfoilData = [];
	handles.phi(:,:) =[];
	handles.psi(:,:) =[];
	handles.phiStr(:,:) =[];
	handles.psiStr(:,:) =[];
	handles.filename = [];
	handles.filepath = [];
	handles.xx = [];
	handles.zU = [];
	handles.zL = [];
	handles.f = [];
	handles.streamSpeed = [];
	handles.cL = [];
	colorbar(handles.axes1,'off');
	handles.colorbarVisible = 0;
	set(handles.uitable1,'data',[]);
	cla(handles.axes1);
	cla(handles.cpAxes);
	legend(handles.cpAxes,'off');
	set(handles.cpAxes,'visible','off')
	handles.elementCounter = 0;
	set(handles.cLText,'String',sprintf(''))
	guidata(hObject, handles);
	figure1_SizeChangedFcn(hObject, 1, handles)
function particleButton_Callback(hObject, eventdata, handles)
	% Start particle Animation
	set(handles.warningText,'String','')
	% Because the animation function can't access handles, communication between
	% the functions has to be done through the UI. The string of the particle
	% button is used for that.
	if strcmp(get(handles.particleButton,'String'),'Start Particles') == true
		set(handles.particleButton,'String','Stop Particles')
		axes(handles.axes1)
		% Use a modified version of MATLAB's streamparticles
		st = stream(handles.streamSpeed, 5, 'Animate', 500, 'ParticleAlignment', 'on', 'Framerate', 60, 'MarkerSize', (handles.windowSize(1)+handles.windowSize(2))/250, 'MarkerFaceColor', 'blue', handles);
		delete(st)
		set(handles.particleButton,'String','Start Particles')
	else 
		set(handles.particleButton,'String','Start Particles')
	end
function expFigButton_Callback(hObject, eventdata, handles)
	% Copy all graphics to new figures
	set(handles.warningText,'String','')
	h1 = handles.axes1;
	f1 = figure;
	s1 = copyobj(h1,f1);
	s1Pos = get(s1,'Position');
	set(s1,'Position',[40 40 s1Pos(3) s1Pos(4)])
	if handles.cpPlotCheckValue == true
		if isempty(handles.airfoilData) == true
			h2 = handles.cpAxes;
			f2 = figure;
			s2 = copyobj(h2,f2);
			s2Pos = get(s2,'Position');
			set(s2,'Position',[40 40 s2Pos(3) s2Pos(4)])
		end
	end
function expPotButton_Callback(hObject, eventdata, handles)
	% Show another window containing the potential function
	try
		a = get(handles.potFig,'Visible');
	end
	if exist('a') ~= 0
		close(handles.potFig)
	else
		% Evaluate the phiStr handle containing the LaTeX code of the potential
		elmsize = size(handles.phiStr);
		if elmsize(1) ~= 0
			phiStr = [handles.phiStr{1,2}];
			psiStr = [handles.psiStr{1,2}];
			for i=2:elmsize(1)
				phiStr = [phiStr,sprintf('+') , handles.phiStr{i,2}];
				psiStr = [psiStr,sprintf('+') , handles.psiStr{i,2}];
			end
			phiStr(strfind(phiStr,' ')) = [];
			psiStr(strfind(psiStr,' ')) = [];
			phiStr = [sprintf('$\\varphi = ') phiStr sprintf('$')];
			psiStr = [sprintf('$\\psi') psiStr sprintf('$')];
		else
			phiStr = '$\\varphi = 0$';
			psiStr = '$\\psi = 0$';
		end
		windowSize = get(gcf,'Position');

		% Create new figure and show the potential there
		handles.potFig = figure('DockControls','off',...
								'MenuBar','none',...
								'NumberTitle','off',...
								'Color','w');

		set(handles.potFig,'Position',[windowSize(1) windowSize(2)-30-50 windowSize(3) 50]);
		handles.potAxes = axes(handles.potFig,'Position', [0 0 1 1], 'Visible', 'off');
		if isempty(handles.airfoilData) == true
			handles.potLabel = text(handles.potAxes, 0.02, 0.5, phiStr,...
									'Interpreter','LaTex',...
									'BackgroundColor','w',...
									'FontSize',14);
			set(handles.warningText,'String','The potential function has been copied to the clipboard.')
			clipboard('copy',phiStr)
		else 
			handles.potLabel = text(handles.potAxes, 0.02, 0.5, 'When an airfoil has been loaded, the potential is too long to show it here. However, it has been copied to the clipboard as LaTeX code',...
									'Interpreter','LaTex',...
									'BackgroundColor','w',...
									'FontSize',14);
			set(handles.warningText,'String','The potential function has been copied to the clipboard.')
			clipboard('copy',phiStr)
		end
	end
	guidata(hObject,handles)
function expDatButton_Callback(hObject, eventdata, handles)
	set(handles.warningText,'String','')

	try
		expMesh = inputdlg('Enter export meshsize:','Export Meshsize',1,{sprintf('%f',handles.meshsize)});
		expMesh = str2num(expMesh{:});

		[fileName, pathToFile] = uiputfile('output.dat');

		% Initialize symbolic variables x and y
		syms x y

		% Summate velocity potential and stream function of every element
		phisum = 0;
		psisum = 0;
		elmsize = size(handles.phi);
		for i=1:elmsize(1)
			phisum = phisum + handles.phi(i,2);
			psisum = psisum + handles.psi(i,2);
		end


		% Create symbolic functions of velocity field, velocity potential and stream
		% function
		um = matlabFunction(diff(phisum,x),'Vars',[x,y]);
		vm = matlabFunction(diff(phisum,y),'Vars',[x,y]);
		phim = matlabFunction(phisum,'Vars',[x,y]);
		psim = matlabFunction(psisum,'Vars',[x,y]);


		% Evaluate velocity field, velocity potential and stream function at mesh
		% points
		[x y] = meshgrid(handles.minX:expMesh:handles.maxX,handles.minY:expMesh:handles.maxY);

		ud = arrayfun(um,x,y);
		vd = arrayfun(vm,x,y);
		phip = arrayfun(phim,x,y);
		psip = arrayfun(psim,x,y);

		tableData = get(handles.uitable1,'data');
		xValues = cell2mat(tableData(2:end,4));
		yValues = cell2mat(tableData(2:end,5));

		ymin = min(abs(y(:,1)));
		[minlip, minlop] = ismember(ymin, y(:,1));
		[minlin, minlon] = ismember(-ymin, y(:,1));
		if minlip == 1
			ymin = y(minlop,1);
		elseif minlin == 1
			ymin = y(minlon,1);
		else
			ymin = 0;
		end

		xmin = min(abs(x(1,:)));
		[minlip, minlop] = ismember(xmin, x(1,:));
		[minlin, minlon] = ismember(-xmin, x(1,:));
		if minlip == 1
			xmin = x(1,minlop);
		elseif minlin == 1
			xmin = x(1,minlon);
		else
			xmin = 0;
		end

		xValues = round(xValues./expMesh).*expMesh + xmin;
		yValues = round(yValues./expMesh).*expMesh + ymin;

		% Because the velocity field of a source is modelled  as 1/r, every source
		% creates a singularity at its  origin. To prevent the velocity to be
		% infinity at  the origin, the meshpoint is 'cut out' of the potential, so
		% the resulting velocity inside equals zero.

		[xli,xlo] = ismember(round(xValues,10),round(x(1,:),10));
		[yli,ylo] = ismember(round(yValues,10),round(y(:,1),10));

		for i = 1:max(size(xlo))
			if xli(i) == 1 && yli(i) == 1
				ud(ylo(i),xlo(i)) = 0;
				vd(ylo(i),xlo(i)) = 0;
				phip(ylo(i),xlo(i)) = (phip(ylo(i)+1,xlo(i))+phip(ylo(i)-1,xlo(i)))/2;
				psip(ylo(i),xlo(i)) = 0;
			end
		end

		expFile = fopen([pathToFile fileName],'w');

		% Calculate pressure distribution
		p = -(ud.^2.+vd.^2);
		% Normalize the pressure distribution, so the highest value is 0
		p = p - max(max(p)) + 1;

		if max(max(p)) == min(min(p))
			p = zeros(size(p));
		else
			p = (p - max(max(p)))/(max(max(p))-min(min(p))) + 1;
		end


		% On the singularities location, set the pressure to the median of 
		% the surrounding pressure.
		p(ylo,xlo) = (p(ylo+1,xlo)+p(ylo-1,xlo))/2;

		% Calculate absolute values of u
		uAbs = sqrt(ud.^2.+vd.^2);

		dlmwrite('p', p);
		dlmwrite('uAbs', uAbs);
		

		if isempty(handles.airfoilData) == false
			% Get the airfoil surface
			z = zeros(size(x,1),size(x,2));

			xCPStart = find(x(1,:) >= 0,1,'first');

			% Create the grid for airfoil evaluation
			if x(1,xCPStart) >= 0 
				countCP = 1/expMesh - 1;
			else
				countCP = 1/expMesh;
			end
			xCP = 0:1:countCP;
			xCP = xCP + xCPStart;

			for i = 1:(countCP+1)
				% Get the index of the x-Value corresponding to the momentary position
				[xCPli,xxCPlo] = ismember(round(x(1,xCP(i)),10),round(handles.xx,10));
				% Get the values of the upper/lower airfoil surface on this x-Value
				zUCP = handles.zU(xxCPlo);
				zLCP = handles.zL(xxCPlo);
				% Find the next meshpoint above the upper surface/below the lower surface
				% Upper surface
				zUexp = find(y(:,1) >= zUCP,1,'first');
				% Lower surface
				zLexp = find(y(:,1) >= zLCP,1,'first') - 1;
				z(zLexp:zUexp,xCP(i)) = 1;
			end
			z = z(:);
			zReshape = sprintf('');
			for o = 1:max(size(z))
				if round((o-1)/5) == (o-1)/5
					zReshape = sprintf('%s \n %e',zReshape, z(o));
				else
					zReshape = sprintf('%s %e',zReshape, z(o));
				end
			end
		end

		i = size(x,1);
		j = size(x,2);

		% Convert Matrices to Vectors
		x = x(:);
		y = y(:);
		ud = ud(:);
		vd = vd(:);
		p = p(:);
		uAbs = uAbs(:);

		% Reshape vectors in rows of five
		xReshape = sprintf('');
		yReshape = sprintf('');
		uReshape = sprintf('');
		vReshape = sprintf('');
		pReshape = sprintf('');
		uAbsReshape = sprintf('');
		for o = 1:max(size(x))
			if round((o-1)/5) == (o-1)/5
				xReshape = sprintf('%s \n %e',xReshape, x(o));
				yReshape = sprintf('%s \n %e',yReshape, y(o));
				uReshape = sprintf('%s \n %e',uReshape, ud(o));
				vReshape = sprintf('%s \n %e',vReshape, vd(o));
				pReshape = sprintf('%s \n %e',pReshape, p(o));
				uAbsReshape = sprintf('%s \n %e',uAbsReshape, uAbs(o));
			else
				xReshape = sprintf('%s %e',xReshape, x(o));
				yReshape = sprintf('%s %e',yReshape, y(o));
				uReshape = sprintf('%s %e',uReshape, ud(o));
				vReshape = sprintf('%s %e',vReshape, vd(o));
				pReshape = sprintf('%s %e',pReshape, p(o));
				uAbsReshape = sprintf('%s %e',uAbsReshape, uAbs(o));
			end
		end

		% Write data to .dat file
		if isempty(handles.airfoilData) == false
			fprintf(expFile, 'TITLE = "Velocity Field"\n VARIABLES = "x"\n "y"\n "z"\n "u"\n "v"\n "p"\n "uAbs"\n ZONE T = "Bild000_vel"\n STRANDID = 0, SOLUTIONTIME = 0\n I = %d, J = %d, K = 1, ZONETYPE = Ordered\n DATAPACKING = BLOCK\n DT = (SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)\n',[i,j]);
			fprintf(expFile, '%s\n %s\n %s\n %s\n %s\n %s\n %s\n', [xReshape, yReshape, zReshape, uReshape, vReshape, pReshape, uAbsReshape]);
		else
			fprintf(expFile, 'TITLE = "Velocity Field"\n VARIABLES = "x"\n "y"\n "u"\n "v"\n "p"\n "uAbs"\n ZONE T = "Bild000_vel"\n STRANDID = 0, SOLUTIONTIME = 0\n I = %d, J = %d, K = 1, ZONETYPE = Ordered\n DATAPACKING = BLOCK\n DT = (SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)\n',[i,j]);
			fprintf(expFile, '%s\n %s\n %s\n %s\n %s\n %s\n', [xReshape, yReshape, uReshape, vReshape, pReshape, uAbsReshape]);
		end
		fclose(expFile);
	end

% .................................. Settings .................................. 

function editMeshsize_Callback(hObject, eventdata, handles)

	handles.meshsize = str2num(get(hObject,'String'));
	handles.airfoilUpdateNecessary = 1;
	guidata(hObject, handles);
function editMaxX_Callback(hObject, eventdata, handles)

	maxXOld = handles.maxX;
	handles.maxX = str2num(get(hObject,'String'));
	if handles.maxX <= handles.minX
		set(handles.warningText,'String','Warning: Max X cannot be less than Min X')
		set(handles.editMaxX,'String',maxXOld)
		handles.maxX = maxXOld;
	end
	if isempty(handles.airfoilData) == false && handles.maxX < 1
		set(handles.warningText,'String','Warning: If an airfoil is loaded, Max X cannot be less than 1')
		set(handles.editMaxX,'String',maxXOld)
		handles.maxX = maxXOld;
	end
	guidata(hObject, handles);
function editMinX_Callback(hObject, eventdata, handles)

	minXOld = handles.minX;
	handles.minX = str2num(get(hObject,'String'));
	if handles.minX >= handles.maxX
		set(handles.warningText,'String','Warning: Min X cannot be greater than Max X')
		set(handles.editMinX,'String',minXOld)
		handles.minX = minXOld;
	end
	if isempty(handles.airfoilData) == false && handles.minX > 0
		set(handles.warningText,'String','Warning: If an airfoil is loaded, Min X cannot be greater than 0')
		set(handles.editMinX,'String',minXOld)
		handles.minX = minXOld;
	end
	guidata(hObject, handles);
function editMaxY_Callback(hObject, eventdata, handles)
	maxYOld = handles.maxY;
	handles.maxY = str2num(get(hObject,'String'));
	if handles.maxY <= handles.minX
		set(handles.warningText,'String','Warning: Max Y cannot be less than Min Y')
		set(handles.editMaxY,'String',maxYOld)
		handles.maxY = maxYOld;
	end
	if isempty(handles.airfoilData) == false && handles.maxY <= max(max(handles.zU))
		set(handles.warningText,'String','Warning: If an airfoil is loaded, Max Y cannot be less than the maximum y-Value of the airfoil.')
		set(handles.editMaxY,'String',maxYOld)
		handles.maxY = maxYOld;
	end
	guidata(hObject, handles);
function editMinY_Callback(hObject, eventdata, handles)
	minYOld = handles.minY;
	handles.minY = str2num(get(hObject,'String'));
	if handles.minY >= handles.maxX
		set(handles.warningText,'String','Warning: Min Y cannot be greater than Max Y')
		set(handles.editMinY,'String',minYOld)
		handles.minY = minYOld;
	end
	if isempty(handles.airfoilData) == false && handles.maxY <= max(max(handles.zU))
		set(handles.warningText,'String','Warning: If an airfoil is loaded, Min Y cannot be greater than the minimum y-Value of the airfoil.')
		set(handles.editMinY,'String',minYOld)
		handles.minY = minYOld;
	end
	guidata(hObject, handles);
function editSLDY_Callback(hObject, eventdata, handles)

	handles.sldy = str2num(get(hObject,'String'));
	guidata(hObject, handles);
function editBeta1_Callback(hObject, eventdata, handles)

	handles.beta1 = str2num(get(hObject,'String'));
	guidata(hObject, handles);
function editBeta2_Callback(hObject, eventdata, handles)

	handles.beta2 = str2num(get(hObject,'String'));
	guidata(hObject, handles);
function streamCheck_Callback(hObject, eventdata, handles)

	handles.streamCheckValue = get(hObject,'Value');

	if handles.aniCheckValue == true && handles.streamCheckValue == true
		set(handles.particleButton,'Enable','on');
		set(handles.particleButton,'ForegroundColor','k');
	else
		set(handles.particleButton,'Enable','inactive');
		set(handles.particleButton,'ForegroundColor',[.5,.5,.5]);
	end
	guidata(hObject, handles);
function potCheck_Callback(hObject, eventdata, handles)

	handles.potCheckValue = get(hObject,'Value');
	guidata(hObject, handles);
function pressCheck_Callback(hObject, eventdata, handles)

	handles.pressCheckValue = get(hObject,'Value');
	guidata(hObject, handles);
function vecCheck_Callback(hObject, eventdata, handles)

	handles.vecCheckValue = get(hObject,'Value');
	guidata(hObject, handles);
function altViewCheck_Callback(hObject, eventdata, handles)

	handles.altViewCheckValue = get(hObject,'Value');
	guidata(hObject, handles);
function symbCheck_Callback(hObject, eventdata, handles)

	handles.symbCheckValue = get(hObject,'Value');
	guidata(hObject, handles);
function cpPlotCheck_Callback(hObject, eventdata, handles)

	handles.cpPlotCheckValue = get(hObject,'Value');
	guidata(hObject, handles);
function xFoilCheck_Callback(hObject, eventdata, handles)

	handles.xFoilCheckValue = get(hObject,'Value');
	try 
		ex = isempty(handles.xFoilLocation);
	end
	if handles.xFoilCheckValue == true && exist('ex') == false
		if exist([handles.scriptPath,'xfoil.exe'],'file') == 2
			% Load xFoil if it is in the same location
			handles.xFoilPath = handles.scriptPath;
			handles.xFoilName = 'xfoil.exe';
			% handles.xFoilLocation = [handles.scriptPath,'xfoil.exe'];
		else
			% If it isn't, let the user point to its location
			[handles.xFoilName, handles.xFoilPath] = uigetfile({'*.*','All Files'},'Please select xfoil.exe');
			% handles.xFoilLocation = [xFoilPath,xFoilName];
		end
	end
	guidata(hObject, handles);
function aniCheck_Callback(hObject, eventdata, handles)

	handles.aniCheckValue = get(hObject,'Value');
	if handles.aniCheckValue == true && handles.streamCheckValue == true
		set(handles.particleButton,'Enable','on');
		set(handles.particleButton,'ForegroundColor','k');
	elseif handles.aniCheckValue == true && handles.streamCheckValue == false
		set(handles.particleButton,'Enable','inactive');
		set(handles.particleButton,'ForegroundColor',[.5,.5,.5]);
		set(handles.warningText,'String','In order to plot the particle animation, streamlines have to be activated!')
	else
		set(handles.particleButton,'Enable','inactive');
		set(handles.particleButton,'ForegroundColor',[.5,.5,.5]);
	end
	guidata(hObject, handles);
function scaleCheck_Callback(hObject, eventdata, handles)

	handles.scaleCheckValue = get(hObject,'Value');
	guidata(hObject, handles);
function equalCheck_Callback(hObject, eventdata, handles)

	handles.equalCheckValue = get(hObject,'Value');
	guidata(hObject, handles);

% ................................ Axes Buttons ................................ 

function yMaxPlusButton_Callback(hObject, eventdata, handles)
	handles.maxY = handles.maxY + handles.meshsize*10;
	[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
	set(handles.editMaxY,'String',handles.maxY)
	guidata(hObject, handles);
function yMaxMinusButton_Callback(hObject, eventdata, handles)
	if handles.maxY - handles.minY > handles.meshsize*10
		handles.maxY = handles.maxY - handles.meshsize*10;
		[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
		set(handles.editMaxY,'String',handles.maxY)
		guidata(hObject, handles);
	end
function yMinPlusButton_Callback(hObject, eventdata, handles)
	handles.minY = handles.minY - handles.meshsize*10;
	[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
	set(handles.editMinY,'String',handles.minY)
	guidata(hObject, handles);
function yMinMinusButton_Callback(hObject, eventdata, handles)
	if handles.maxY - handles.minY > handles.meshsize*10
		handles.minY = handles.minY + handles.meshsize*10;
		[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
		set(handles.editMinY,'String',handles.minY)
		guidata(hObject, handles);
	end
function xMaxPlusButton_Callback(hObject, eventdata, handles)
	handles.maxX = handles.maxX + handles.meshsize*10;
	[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
	set(handles.editMaxX,'String',handles.maxX)
	guidata(hObject, handles);
function xMaxMinusButton_Callback(hObject, eventdata, handles)
	if handles.maxX - handles.minX > handles.meshsize*10
		handles.maxX = handles.maxX - handles.meshsize*10;
		[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
		set(handles.editMaxX,'String',handles.maxX)
		guidata(hObject, handles);
	end
function xMinPlusButton_Callback(hObject, eventdata, handles)
	handles.minX = handles.minX - handles.meshsize*10;
	[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
	set(handles.editMinX,'String',handles.minX)
	guidata(hObject, handles);
function xMinMinusButton_Callback(hObject, eventdata, handles)
	if handles.maxX - handles.minX > handles.meshsize*10
		handles.minX = handles.minX + handles.meshsize*10;
		[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);
		set(handles.editMinX,'String',handles.minX)
		guidata(hObject, handles);
	end
function redrawButton_Callback(hObject, eventdata, handles)

	% Update plot
	[handles.colorbarVisible, handles.streamSpeed] = plotAxes(hObject,handles);

	% Update handles structure
	guidata(hObject, handles);

% .............................. Resize Function ...............................

function figure1_SizeChangedFcn(hObject, eventdata, handles)

	% Executes when window is resized

	windowSize = get(gcf,'Position');

	try
		set(handles.potFig,'Position',[windowSize(1) windowSize(2)-30-50 windowSize(3) 50]);
	end

	% Limit window x and y dimensions
	if windowSize(3) < handles.windowDefaultPosition(3)
		windowSize(3) = handles.windowDefaultPosition(3);
	end
	if windowSize(4) < handles.windowDefaultPosition(4)
		windowSize(4) = handles.windowDefaultPosition(4);
	end

	set(gcf,'Position',windowSize);

	windowSizeGet = get(gcf,'Position');
	windowSize = [windowSizeGet(3) windowSizeGet(4) 0 0];
	
	if handles.colorbarVisible(1) == 1
		compOS = computer;
		if strcmp(compOS,'PCWIN64') == true || strcmp(compOS,'PCWIN') == true
			windowSizeAxes = [0 0 windowSizeGet(3)-75 windowSizeGet(4)];
		else
			windowSizeAxes = [0 0 windowSizeGet(3)-50 windowSizeGet(4)];
		end
	else
		windowSizeAxes = [0 0 windowSizeGet(3) windowSizeGet(4)];	
	end
	windowSizeAxesSettings = [windowSizeGet(3) windowSizeGet(4) 0 0];

	windowSizeCPAxes = [windowSizeGet(3) 0 0 windowSizeGet(4)];	
	axesPositionTemp = get(handles.axes1,'Position');


	xPosition = axesPositionTemp(1) + axesPositionTemp(3)/2;
	yPosition = axesPositionTemp(2) + axesPositionTemp(4)/2;

	windowXAxesButtonSettings = [xPosition 0 0 0];
	windowYAxesButtonSettings = [0 yPosition 0 0];

	if handles.colorbarVisible(1) == 1
		windowSizeSettings = [xPosition+25 windowSizeGet(4) 0 0];
	else
		windowSizeSettings = [xPosition windowSizeGet(4) 0 0];
	end

	windowSizeCL = [windowSize(1) 0 0 0];

	handles.elementMenuPosition 		= handles.elementMenuDefaultPosition 		+ windowSize;
	handles.strengthEditPosition 		= handles.strengthEditDefaultPosition 		+ windowSize;
	handles.strengthTextPosition 		= handles.strengthTextDefaultPosition 		+ windowSize;
	handles.posXEditPosition 			= handles.posXEditDefaultPosition 			+ windowSize;
	handles.posXTextPosition 			= handles.posXTextDefaultPosition 			+ windowSize;
	handles.posYEditPosition 			= handles.posYEditDefaultPosition 			+ windowSize;
	handles.posYTextPosition 			= handles.posYTextDefaultPosition 			+ windowSize;
	handles.okButtonPosition 			= handles.okButtonDefaultPosition 			+ windowSize;
	handles.resetButtonPosition 		= handles.resetButtonDefaultPosition 		+ windowSize;
	handles.particleButtonPosition 		= handles.particleButtonDefaultPosition 	+ windowSize;
	handles.airFoilLoadButtonPosition 	= handles.airFoilLoadButtonDefaultPosition 	+ windowSize;
	handles.settingsPosition 			= handles.settingsDefaultPosition 			+ windowSize;
	handles.expFigButtonPosition 		= handles.expFigButtonDefaultPosition 		+ windowSize;
	handles.expPotButtonPosition 		= handles.expPotButtonDefaultPosition 		+ windowSize;
	handles.expDatButtonPosition 		= handles.expDatButtonDefaultPosition 		+ windowSize;
	handles.cLTextPosition 				= handles.cLTextDefaultPosition 			+ windowSizeCL;

	handles.tablePosition 				= handles.tableDefaultPosition 				+ windowSize;

	handles.streamCheckPosition 		= handles.streamCheckDefaultPosition 		+ windowSizeSettings;
	handles.potCheckPosition 			= handles.potCheckDefaultPosition 			+ windowSizeSettings;
	handles.pressCheckPosition 			= handles.pressCheckDefaultPosition 		+ windowSizeSettings;
	handles.vecCheckPosition 			= handles.vecCheckDefaultPosition 			+ windowSizeSettings;
	handles.altViewCheckPosition 		= handles.altViewCheckDefaultPosition 		+ windowSizeSettings;
	handles.symbCheckPosition 			= handles.symbCheckDefaultPosition 			+ windowSizeSettings;
	handles.cpPlotCheckPosition 		= handles.cpPlotCheckDefaultPosition 		+ windowSizeSettings;
	handles.xFoilCheckPosition 			= handles.xFoilCheckDefaultPosition 		+ windowSizeSettings;
	handles.aniCheckPosition 			= handles.aniCheckDefaultPosition 			+ windowSizeSettings;
	handles.scaleCheckPosition 			= handles.scaleCheckDefaultPosition 		+ windowSizeSettings;
	handles.equalCheckPosition 			= handles.equalCheckDefaultPosition 		+ windowSizeSettings;

	handles.editMeshsizePosition 		= handles.editMeshsizeDefaultPosition 		+ windowSizeSettings;
	handles.editSLDYPosition 			= handles.editSLDYDefaultPosition 			+ windowSizeSettings;
	handles.editBeta1Position 			= handles.editBeta1DefaultPosition 			+ windowSizeSettings;
	handles.editBeta2Position 			= handles.editBeta2DefaultPosition 			+ windowSizeSettings;
	handles.editMaxXPosition 			= handles.editMaxXDefaultPosition 			+ windowSizeSettings;
	handles.editMinXPosition 			= handles.editMinXDefaultPosition 			+ windowSizeSettings;
	handles.editMaxYPosition 			= handles.editMaxYDefaultPosition 			+ windowSizeSettings;
	handles.editMinYPosition 			= handles.editMinYDefaultPosition 			+ windowSizeSettings;

	handles.textMeshsizePosition 		= handles.textMeshsizeDefaultPosition 		+ windowSizeSettings;
	handles.textSLDYPosition 			= handles.textSLDYDefaultPosition 			+ windowSizeSettings;
	handles.textBeta1Position 			= handles.textBeta1DefaultPosition 			+ windowSizeSettings;
	handles.textBeta2Position 			= handles.textBeta2DefaultPosition 			+ windowSizeSettings;
	handles.textMaxXPosition 			= handles.textMaxXDefaultPosition 			+ windowSizeSettings;
	handles.textMinXPosition 			= handles.textMinXDefaultPosition 			+ windowSizeSettings;
	handles.textMaxYPosition 			= handles.textMaxYDefaultPosition 			+ windowSizeSettings;
	handles.textMinYPosition 			= handles.textMinYDefaultPosition 			+ windowSizeSettings;

	handles.axesPosition 				= handles.axesDefaultPosition 				+ windowSizeAxes;
	handles.cpAxesPosition 				= handles.cpAxesDefaultPosition 			+ windowSizeCPAxes;
	handles.slaAxesPosition 			= handles.slaAxesDefaultPosition 			+ windowSizeSettings;

	handles.yMaxPlusButtonPosition 		= handles.yMaxPlusButtonDefaultPosition 	+ windowYAxesButtonSettings;
	handles.yMaxMinusButtonPosition 	= handles.yMaxMinusButtonDefaultPosition 	+ windowYAxesButtonSettings;
	handles.yMinPlusButtonPosition 		= handles.yMinPlusButtonDefaultPosition 	+ windowYAxesButtonSettings;
	handles.yMinMinusButtonPosition 	= handles.yMinMinusButtonDefaultPosition 	+ windowYAxesButtonSettings;
	handles.yPanelPosition 				= handles.yPanelDefaultPosition 			+ windowYAxesButtonSettings;
	handles.yTextPosition 				= handles.yTextDefaultPosition 				+ windowYAxesButtonSettings;

	handles.xMaxPlusButtonPosition 		= handles.xMaxPlusButtonDefaultPosition 	+ windowXAxesButtonSettings;
	handles.xMaxMinusButtonPosition 	= handles.xMaxMinusButtonDefaultPosition 	+ windowXAxesButtonSettings;
	handles.xMinPlusButtonPosition 		= handles.xMinPlusButtonDefaultPosition 	+ windowXAxesButtonSettings;
	handles.xMinMinusButtonPosition 	= handles.xMinMinusButtonDefaultPosition 	+ windowXAxesButtonSettings;
	handles.xPanelPosition 				= handles.xPanelDefaultPosition 			+ windowXAxesButtonSettings;
	handles.xTextPosition 				= handles.xTextDefaultPosition 				+ windowXAxesButtonSettings;


	set(handles.elementMenu,'Position',handles.elementMenuPosition);
	set(handles.strengthEdit,'Position',handles.strengthEditPosition); 
	set(handles.strengthText,'Position',handles.strengthTextPosition); 
	set(handles.posXEdit,'Position',handles.posXEditPosition); 
	set(handles.posXText,'Position',handles.posXTextPosition); 
	set(handles.posYEdit,'Position',handles.posYEditPosition); 
	set(handles.posYText,'Position',handles.posYTextPosition); 
	set(handles.okbutton,'Position',handles.okButtonPosition);
	set(handles.resetButton,'Position',handles.resetButtonPosition);
	set(handles.particleButton,'Position',handles.particleButtonPosition);
	set(handles.airFoilLoadButton,'Position',handles.airFoilLoadButtonPosition);
	set(handles.settingsButton,'Position',handles.settingsPosition);
	set(handles.expFigButton,'Position',handles.expFigButtonPosition);
	set(handles.expPotButton,'Position',handles.expPotButtonPosition);
	set(handles.expDatButton,'Position',handles.expDatButtonPosition);
	set(handles.cLText,'Position',handles.cLTextPosition);

	set(handles.uitable1,'Position',handles.tablePosition); 

	set(handles.streamCheck,'Position',handles.streamCheckPosition);
	set(handles.potCheck,'Position',handles.potCheckPosition);
	set(handles.pressCheck,'Position',handles.pressCheckPosition);
	set(handles.vecCheck,'Position',handles.vecCheckPosition);
	set(handles.altViewCheck,'Position',handles.altViewCheckPosition);
	set(handles.symbCheck,'Position',handles.symbCheckPosition);
	set(handles.cpPlotCheck,'Position',handles.cpPlotCheckPosition);
	set(handles.xFoilCheck,'Position',handles.xFoilCheckPosition);
	set(handles.aniCheck,'Position',handles.aniCheckPosition);
	set(handles.scaleCheck,'Position',handles.scaleCheckPosition);
	set(handles.equalCheck,'Position',handles.equalCheckPosition);

	set(handles.editMeshsize,'Position',handles.editMeshsizePosition);
	set(handles.editSLDY,'Position',handles.editSLDYPosition);
	set(handles.editBeta1,'Position',handles.editBeta1Position);
	set(handles.editBeta2,'Position',handles.editBeta2Position);
	set(handles.editMaxX,'Position',handles.editMaxXPosition);
	set(handles.editMinX,'Position',handles.editMinXPosition);
	set(handles.editMaxY,'Position',handles.editMaxYPosition);
	set(handles.editMinY,'Position',handles.editMinYPosition);

	set(handles.textMeshsize,'Position',handles.textMeshsizePosition);
	set(handles.textSLDY,'Position',handles.textSLDYPosition);
	set(handles.textBeta1,'Position',handles.textBeta1Position);
	set(handles.textBeta2,'Position',handles.textBeta2Position);
	set(handles.textMaxX,'Position',handles.textMaxXPosition);
	set(handles.textMinX,'Position',handles.textMinXPosition);
	set(handles.textMaxY,'Position',handles.textMaxYPosition);
	set(handles.textMinY,'Position',handles.textMinYPosition);

	set(handles.axes1,'Position',handles.axesPosition); 
	set(handles.cpAxes,'Position',handles.cpAxesPosition); 
	set(handles.slaAxes,'Position',handles.slaAxesPosition); 

	set(handles.yMaxPlusButton,'Position',handles.yMaxPlusButtonPosition);
	set(handles.yMaxMinusButton,'Position',handles.yMaxMinusButtonPosition);
	set(handles.yMinPlusButton,'Position',handles.yMinPlusButtonPosition);
	set(handles.yMinMinusButton,'Position',handles.yMinMinusButtonPosition);
	set(handles.yPanel,'Position',handles.yPanelPosition);
	set(handles.yText,'Position',handles.yTextPosition);
	
	set(handles.xMaxPlusButton,'Position',handles.xMaxPlusButtonPosition);
	set(handles.xMaxMinusButton,'Position',handles.xMaxMinusButtonPosition);
	set(handles.xMinPlusButton,'Position',handles.xMinPlusButtonPosition);
	set(handles.xMinMinusButton,'Position',handles.xMinMinusButtonPosition);
	set(handles.xPanel,'Position',handles.xPanelPosition);
	set(handles.xText,'Position',handles.xTextPosition);

	if handles.equalCheckValue == true
		oldMaxX = str2num(get(handles.editMaxX,'String'));
		oldMinX = str2num(get(handles.editMinX,'String'));
		oldMaxY = str2num(get(handles.editMaxY,'String'));
		oldMinY = str2num(get(handles.editMinY,'String'));
		axis(handles.axes1,'equal');
		% Calculate the axis limits for equal axis
		xLimits = get(handles.axes1,'XLim');
		yLimits = get(handles.axes1,'YLim');
		
		handles.minX = oldMinX;
		handles.maxX = oldMaxX;
		handles.minY = oldMinY;
		handles.minY = oldMinY;
		% handles.minX = xLimits(1) - mod(xLimits(1),handles.meshsize) + handles.meshsize;
		% handles.maxX = xLimits(2) - mod(xLimits(2),handles.meshsize);
		% handles.minY = yLimits(1) - mod(yLimits(1),handles.meshsize) + handles.meshsize;
		% handles.maxY = yLimits(2) - mod(yLimits(2),handles.meshsize);
		set(handles.editMaxX,'String',handles.maxX);
		set(handles.editMinX,'String',handles.minX);
		set(handles.editMaxY,'String',handles.maxY);
		set(handles.editMinY,'String',handles.minY);
		axis(handles.axes1,[handles.minX handles.maxX handles.minY handles.maxY]);
	else
		axis(handles.axes1,'normal');
	end

	guidata(hObject, handles);

% ............................ Particle Animation ..............................

function hout = stream(varargin)
	[cax,args,nargs] = axescheck(varargin{:});
	[h, verts, n, animate, framerate, partalign, props, handles] = ...
	    parseargs(nargs-1, args);

	handles = handles{1};

	% Set default values
	if isempty(n)
	    n = 1;
	end

	if isempty(animate)
	    animate = 0;
	end

	if isempty(framerate)
	    framerate = inf;
	end
	framerate = 1/framerate;

	if isempty(partalign)
	    partalign = 'off';
	end

	% Create a line if needed
	if isempty(h)
	    if isempty(cax)
	        cax = gca;
	    end
	    h = line(nan,nan,'parent',cax);
	end
	set(h, 'linestyle', 'none', 'marker', 'o', ...
	    'markeredgecolor', 'none', 'markerfacecolor', 'red');

	if ~isempty(props)
	    set(h, props)
	end

	% if it's 2D, make it 3D
	vv=cat(1, verts{:});
	if size(vv,2)==2
	    vv(:,3) = 0;
	end

	% This try/catch block allows the user to close the figure gracefully
	% during the streamparticles animation.
	try
	    if strcmp(partalign, 'off')
	        % Evenly distributed particles
	        len = size(vv,1);
	        if n<=1
	            n = n*len;
	        end
	        inc = ceil(len/n);

	        set(h, 'xdata', vv(1:inc:end,1), ...
	            'ydata', vv(1:inc:end,2), ...
	            'zdata', vv(1:inc:end,3))
	        breakTrue = 0;
	        for j = 1:animate
	            for k = 1:inc;
	                if framerate>0
	                    t0 = clock;
	                    while(etime(clock,t0)<framerate); end;

                    	if strcmp(get(handles.particleButton,'String'),'Stop Particles') ~= true
			        		breakTrue = 1;
		            		break
		        		end
	                end
	                if breakTrue == 1;
	                	break
	                end
	                set(h, 'xdata', vv(k:inc:end,1), ...
	                    'ydata', vv(k:inc:end,2), ...
	                    'zdata', vv(k:inc:end,3))
	                drawnow;
	            end
	            if breakTrue == 1;
                	break
                end
	        end
	    else
	        % Particles aligned with start of streamlines
	        lengths = cellfun('size', verts,1);
	        %for j = 1:length(verts)
	        %  lengths(j) = size(verts{j},1);
	        %end
	        endpos = cumsum(lengths);
	        startpos = [1 endpos(1:end-1)+1];
	        inc = ceil(max(lengths)/n);
	        index = [];
	        for j = 1:length(startpos)
	            index = [index startpos(j):inc:endpos(j)];
	        end
	        set(h, 'xdata', vv(index,1), ...
	            'ydata', vv(index,2), ...
	            'zdata', vv(index,3))
	        breakTrue = 0;
	        for i = 1:animate
	            for k = 1:inc
	                index = [];
	                for j = 1:length(startpos)
	                    index = [index startpos(j)+k:inc:endpos(j)];
	                end
	                if framerate>0
	                    t0 = clock;

	                    while(etime(clock,t0)<framerate); end;
			        	if strcmp(get(handles.particleButton,'String'),'Stop Particles') ~= true
			        		breakTrue = 1;
		            		break
		        		end
	                end
	                if breakTrue == 1;
	                	break
	                end
	                set(h, 'xdata', vv(index,1), ...
	                    'ydata', vv(index,2), ...
	                    'zdata', vv(index,3))
	                drawnow;
	            end
	            if breakTrue == 1;
                	break
                end
	        end
	    end
	catch E
	    if ~strcmp(E.identifier, 'MATLAB:class:InvalidHandle')
	        rethrow(E);
	    end
	end

	if nargout > 0
	    hout = h;
	end
function [h, verts, n, animate, framerate, partalign, props, handles] = parseargs(nin, vargin)

	n = [];
	animate = [];
	framerate = [];
	partalign = [];
	props = [];

	handles = vargin(end);

	if nin==0
	    error(message('MATLAB:streamparticles:WrongNumberOfInputs'));
	else    % streamparticles(h,...) or streamparticles(verts) or streamparticles(verts,n)
	    h = vargin{1};
	    if all(ishandle(h)) && all(strcmp(get(h, 'type'), 'line'))
	        nin = nin-1;
	        vargin = vargin(2:end);
	    else
	        h = [];
	    end
	    verts = vargin{1};

	    if nin>=2   % param value pairs
	        if ischar(vargin{2})
	            pos = 2;
	        else
	            n = vargin{2};
	            pos = 3;
	            if nin==3
	                error(message('MATLAB:streamparticles:WrongNumberOfInputs'));
	            end
	        end

	        while pos<nin
	            pname = lower(vargin{pos});
	            if ~ischar(pname)
	                error(message('MATLAB:streamparticles:NonStringPVPair'));
	            end
	            if pos+1>nin
	                error(message('MATLAB:streamparticles:MissingPVPair'));
	            end
	            pval = vargin{pos+1};

	            if strcmp(pname, 'animate')
	                animate = pval;
	            elseif strcmp(pname, 'framerate')
	                framerate = pval;
	            elseif strcmp(pname, 'particlealignment')
	                partalign = lower(pval);
	            else
	                props.(pname) = pval;
	            end
	            pos = pos+2;
	        end
	    end
	end

% ................................ End of Code .................................


function editBeta1_CreateFcn(hObject, eventdata, handles)

	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end




function editBeta2_CreateFcn(hObject, eventdata, handles)
	
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
