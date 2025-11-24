% Displays data from a single electrode. Modified from
% displaySingleChannelIC in the predictive coding project.

% This program only uses data already saved in savedData folder

% Run as follows:
% displaySingleChannelNIL('dona','071024','NIL_001');
% displaySingleChannelNIL('jojo','260525','NIL_001');
% displaySingleChannelNIL('jojo','280725','NIL_001');

function displaySingleChannelNIL(subjectName,expDate,protocolName,folderSourceString,gridType,gridLayout)

if ~exist('folderSourceString','var');  folderSourceString='';          end
if ~exist('gridType','var');            gridType='Microelectrode';      end
if ~exist('gridLayout','var');          gridLayout=2;                   end

if isempty(folderSourceString); folderSourceString = pwd;               end

folderSavedData = fullfile(folderSourceString,'savedData');

% get information about highRMSElectrodes 
tmp = load(fullfile(folderSavedData,'rfData',[subjectName gridType 'RFData.mat']));
highRMSElectrodes = tmp.highRMSElectrodes;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16;
% Panel position details
allPanelsHeight = 0.2; allPanelsStartHeight = 0.775;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Parameters & Options Panel %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramsPanelPos = [0.35 allPanelsStartHeight+allPanelsHeight/2 0.3 allPanelsHeight/2];
numEntries = 2;

hParamsPanel = uipanel('Title','Parameters','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',paramsPanelPos);

% Electrodes
uicontrol('Parent',hParamsPanel,'Unit','Normalized', ...
    'Position',[0 1-1/numEntries 0.5 1/numEntries],...
    'Style','text','String','Electrode Number','HorizontalAlignment','left','FontSize',fontSizeMedium);
hElectrode = uicontrol('Parent',hParamsPanel,'Unit','Normalized', ...
    'Position',[0.5 1-1/numEntries 0.5 1/numEntries], ...
    'Style','popup','String',highRMSElectrodes,'FontSize',fontSizeMedium);

% Stim Type
stimTypeString = 'Color|Grayscale';
uicontrol('Parent',hParamsPanel,'Unit','Normalized', ...
    'Position',[0 1-2/numEntries 0.25 1/numEntries], ...
    'Style','text','String','Stim Type','HorizontalAlignment','left','FontSize',fontSizeMedium);
hStimType = uicontrol('Parent',hParamsPanel,'Unit','Normalized', ...
    'Position',[0.25 1-2/numEntries 0.25 1/numEntries], ...
    'Style','popup','String',stimTypeString,'FontSize',fontSizeMedium);

% Features
featureDetails = load(fullfile(folderSavedData,'features',[subjectName '_r1.mat']));
featureTypeString = featureDetails.measure_type;
uicontrol('Parent',hParamsPanel,'Unit','Normalized', ...
    'Position',[0.5 1-2/numEntries 0.25 1/numEntries], ...
    'Style','text','String','Feature','HorizontalAlignment','left','FontSize',fontSizeMedium);
hFeatureType = uicontrol('Parent',hParamsPanel,'Unit','Normalized', ...
    'Position',[0.75 1-2/numEntries 0.25 1/numEntries], ...
    'Style','popup','String',featureTypeString,'FontSize',fontSizeMedium);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Options Panel
optPanelPos = [0.35 allPanelsStartHeight 0.3 allPanelsHeight/2];
hOptionsPanel = uipanel('Unit','Normalized','Position',optPanelPos);
numEntries = 2;

% Clear All
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-1/numEntries 0.5 1/numEntries], ...
    'Style','pushbutton','String','Clear','FontSize',fontSizeMedium, ...
    'Callback',{@cla_Callback});

% Plot
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-2/numEntries 0.5 1/numEntries], ...
    'Style','pushbutton','String','Plot','FontSize',fontSizeMedium, ...
    'Callback',{@plotData_Callback});

% Rescale XYZ
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 1-1/numEntries 0.5 1/numEntries], ...
    'Style','pushbutton','String','Rescale X','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleData_Callback});

uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 1-2/numEntries 0.5 1/numEntries], ...
    'Style','pushbutton','String','Rescale Z','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleZ_Callback});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Timing Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timingPanelPos = [0.65 allPanelsStartHeight 0.3 allPanelsHeight];
hTimingPanel = uipanel('Title','Timing (Min,Max)',...
    'fontSize', fontSizeLarge,'Unit','Normalized','Position',timingPanelPos);
numEntries = 5;

% Signal Range
signalRange = [-0.7 2];
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-1/numEntries 0.5 1/numEntries], ...
    'Style','text','String','Signal Range (s)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hStimMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-1/numEntries 0.25 1/numEntries], ...
    'Style','edit','String',num2str(signalRange(1)),'FontSize',fontSizeSmall);
hStimMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-1/numEntries 0.25 1/numEntries], ...
    'Style','edit','String',num2str(signalRange(2)),'FontSize',fontSizeSmall);

% Baseline
baseline = [-0.5 0];
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-2/numEntries 0.5 1/numEntries], ...
    'Style','text','String','Baseline Duration (s)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hBaselineMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-2/numEntries 0.25 1/numEntries], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeSmall);
hBaselineMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-2/numEntries 0.25 1/numEntries], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeSmall);

% Stim Period
stimPeriod = [0.25 0.75];
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-3/numEntries 0.5 1/numEntries], ...
    'Style','text','String','Stimulus Duration (s)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hStimPeriodMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-3/numEntries 0.25 1/numEntries], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall);
hStimPeriodMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-3/numEntries 0.25 1/numEntries], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall);

% FFT Range
fftRange = [0 100];
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-4/numEntries 0.5 1/numEntries], ...
    'Style','text','String','FFT Range (Hz)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hFFTMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-4/numEntries 0.25 1/numEntries], ...
    'Style','edit','String',num2str(fftRange(1)),'FontSize',fontSizeSmall);
hFFTMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-4/numEntries 0.25 1/numEntries], ...
    'Style','edit','String',num2str(fftRange(2)),'FontSize',fontSizeSmall);

% Z Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-5/numEntries 0.5 1/numEntries], ...
    'Style','text','String','Z Range','HorizontalAlignment','left','FontSize',fontSizeSmall);
hZMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-5/numEntries 0.25 1/numEntries], ...
    'Style','edit','String','0','FontSize',fontSizeSmall);
hZMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-5/numEntries 0.25 1/numEntries], ...
    'Style','edit','String','1','FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get plots and message handles

% Get electrode array information
electrodeGridPos = [0.05 allPanelsStartHeight 0.3 allPanelsHeight];
showElectrodeLocations(electrodeGridPos,highRMSElectrodes,'b',[],1,0,gridType,subjectName,gridLayout);

% Main plot handles
numImages = size(featureDetails.feat_tensor,1);
numTypes = length(string(strsplit(stimTypeString, '|')));
numImagesPerType = numImages/numTypes;
numRows = 8; numCols = numImagesPerType/numRows;
hImagePatches = getPlotHandles(numRows,numCols,[0.05 0.05 0.35 0.7]);
hTF = getPlotHandles(numRows,numCols,[0.45 0.05 0.35 0.7]);
hERP = subplot('position',[0.85 0.625 0.1 0.125]);
hFR = subplot('position',[0.85 0.45 0.1 0.125]);
hDeltaPSD = subplot('position',[0.85 0.25 0.1 0.15]);
hCorr = subplot('position',[0.85 0.05 0.1 0.15]);

colorNames = jet(numImagesPerType);
colormap jet

% Get all data
patchDetails = load(fullfile(folderSavedData,'patches',[subjectName '_hl2.mat']));

blRangeInUse = [str2double(get(hBaselineMin,'String')) str2double(get(hBaselineMax,'String'))];
stRangeInUse = [str2double(get(hStimPeriodMin,'String')) str2double(get(hStimPeriodMax,'String'))];
fileName = fullfile(folderSavedData,'responses', ...
                [subjectName '_' expDate '_' protocolName(1:3) '_' num2str(str2double(protocolName(5:7))) ...
                '_bl_' num2str(blRangeInUse(1)) '_' num2str(blRangeInUse(2)) ...
                '_st_' num2str(stRangeInUse(1)) '_' num2str(stRangeInUse(2)) '_.mat']);
responseDetails = load(fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
    function plotData_Callback(~,~)

        electrodeNum = highRMSElectrodes(get(hElectrode,'val'));

        stimIndices =  (1:numImagesPerType) + numImagesPerType*(get(hStimType,'val')-1);
        featureIndex = get(hFeatureType,'val');

        blRange = [str2double(get(hBaselineMin,'String')) str2double(get(hBaselineMax,'String'))];
        stRange = [str2double(get(hStimPeriodMin,'String')) str2double(get(hStimPeriodMax,'String'))];
        
        signalRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        fftRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];

        %%%%%%%%%%%%%%%%%%%%%%%% Get resposeDetails %%%%%%%%%%%%%%%%%%%%%%%
        % Get responses if responseDetails does nto exist or if stimulus or baseline periods have changed
        fileName = fullfile(folderSavedData,'responses', ...
                [subjectName '_' expDate '_' protocolName(1:3) '_' num2str(str2double(protocolName(5:7))) ...
                '_bl_' num2str(blRange(1)) '_' num2str(blRange(2)) ...
                '_st_' num2str(stRange(1)) '_' num2str(stRange(2)) '_.mat']);

        if  ~isequal(blRange,blRangeInUse) || ~isequal(stRange,stRangeInUse)
            disp('bl or st range modified. Loading responseDetails for new range...')
            responseDetails = load(fileName);
            blRangeInUse = blRange;
            stRangeInUse = stRange;
        end

        %%%%%%%%%%%%%% Get electrode specific information %%%%%%%%%%%%%%%%
        patches = patchDetails.patch_table(stimIndices,electrodeNum);
        responses = responseDetails.response_table(stimIndices,electrodeNum);
        featureVals = featureDetails.feat_tensor(stimIndices,electrodeNum,featureIndex);

        [~,sortIndex] = sort(featureVals);

        % Plot
        hold(hERP,'on'); hold(hFR,'on'); hold(hDeltaPSD,'on');

        for i=1:numImagesPerType
            pos = sortIndex(i);
    
            % Plot Patch
            image(cell2mat(patches{pos,1}),'Parent',hImagePatches(i)); % Plot Patch
            set(hImagePatches(i),'XTickLabel',[],'YTickLabel',[]);

            % Plot dTF
            pcolor(hTF(i),responseDetails.t_TF,responseDetails.f_TF,responses{pos,1}.del_TF);
            shading(hTF(i),'interp');
            axis(hTF(i),[signalRange fftRange]);
            if i~=numImagesPerType
                set(hTF(i),'XTickLabel',[],'YTickLabel',[]);
            end

            plot(hERP,responseDetails.t,responses{pos,1}.ERP,'color',colorNames(i,:)); % ERP
            plot(hFR,responseDetails.t_FR,responses{pos,1}.FR,'color',colorNames(i,:)); % Firing Rate
            plot(hDeltaPSD,responseDetails.f_st,responses{pos,1}.del_PSD,'color',colorNames(i,:)); % Delta PSD
        end

        % Rescale zLims
        zRange = getZLims(hTF);
        set(hZMin,'String',num2str(zRange(1))); set(hZMax,'String',num2str(zRange(2)));
        rescaleZPlots(hTF,zRange);
        
        xlim(hERP,signalRange);
        xlim(hFR,signalRange);
        xlim(hDeltaPSD,fftRange);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleZ_Callback(~,~)
        zRange = [str2double(get(hZMin,'String')) str2double(get(hZMax,'String'))];
        rescaleZPlots(plotHandles,zRange);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleData_Callback(~,~)

        signalRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        fftRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
        
        rescaleData(hTF,[signalRange fftRange]);
        xlim(hERP,signalRange); 
        xlim(hFR,signalRange); 
        xlim(hDeltaPSD,fftRange);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cla_Callback(~,~)
        
        claGivenPlotHandle(hImagePatches);
        claGivenPlotHandle(hTF);
        cla(hERP); cla(hFR); cla(hDeltaPSD); cla(hCorr); 

        function claGivenPlotHandle(plotHandles)
            [nRows,nCols] = size(plotHandles);
            for i=1:nRows
                for j=1:nCols
                    cla(plotHandles(i,j));
                    title("",'Parent',plotHandles);
                end
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zLims = getZLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
zMin = inf;
zMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        tmpAxisVals = clim(plotHandles(row,column));
        if tmpAxisVals(1) < zMin
            zMin = tmpAxisVals(1);
        end
        if tmpAxisVals(2) > zMax
            zMax = tmpAxisVals(2);
        end
    end
end

zLims=[zMin zMax];
end
function rescaleData(plotHandles,axisLims)

[numRows,numCols] = size(plotHandles);
labelSize=12;
for i=1:numRows
    for j=1:numCols
        axis(plotHandles(i,j),axisLims);
        if (i==numRows && rem(j,2)==1)
            if j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        else
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        end
    end
end
end
function rescaleZPlots(plotHandles,zLims)
[numRow,numCol] = size(plotHandles);

for i=1:numRow
    for j=1:numCol
        clim(plotHandles(i,j),zLims);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%