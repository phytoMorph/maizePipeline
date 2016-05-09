function [varargout] = cFlowLoader(varargin)
    varargout = {};
    for e = 1:numel(varargin)
        fidx = strfind(varargin{e},'@');
        loadFile = varargin{e}(1:fidx-1);
        varName = varargin{e}(fidx+1:end);
%        loadFile = strrep(loadFile,'/functionOutputs/','/functionOutputs/output/');
        load(loadFile,varName);
        eval(['varargout{e} = ' varName ';']);
    end
end