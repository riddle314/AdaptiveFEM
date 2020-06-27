% A class of constant values
classdef Constants
    
    properties (Constant)
        % The modes of FEM
        ADAPTIVE_FEM = 1;
        REGULAR_FEM = 2;
        
        % Constant strings for naming
        PERCENTAGE_OF_ERROR = 'percentageOfError';
        ADAPTIVE_PERCENTAGE_OF_ERROR = 'adaptivePercentageOfError';
        ADAPTIVE_PERC_ERROR = 'adaptivePercError';
        MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR = 'minimumBoundaryOfAPosterioriError';
        ADAPTIVE_FEM_TITLE = 'Adaptive FEM';
        REGULAR_FEM_TITLE = 'Regular FEM';
        ADAPTIVE_FEM_TITLE_WITH_DASH = 'Adaptive_FEM';
        REGULAR_FEM_TITLE_WITH_DASH = 'Regular_FEM';
        TIME_OF_CALCULATION = 'Time of Calculation';
        A_POSTERIORI_ERROR = 'aPosterioriError';
        NUMBER_OF_NODES = 'number of nodes';
        DASH = '_';
        COLON = ': ';
        COMMA = ', ';
        LEFT_SLASH = '\';
        JPG_TYPE = '.jpg';
        FIG_TYPE = '.fig';
        FOLDER_ROOT = 'results';
    end
end