% An utility class with usefull functions
classdef UtilsClass
    
    methods(Static)
        
        % creates and returns a folder based on the inputs
        function folderPath = createFolderPathPerModeOfMethod(minimumBoundaryOfAPosterioriError, modeOfMethod, isPercentageOfErrorAdaptive)
            folderNameEnd = Constants.REGULAR_FEM_TITLE_WITH_DASH;
            if modeOfMethod == Constants.ADAPTIVE_FEM
                % setup the percentage of error type string based on if the percentage of error is adaptive
                percentageOfErrorTypeString = Constants.PERCENTAGE_OF_ERROR;
                if isPercentageOfErrorAdaptive
                    percentageOfErrorTypeString = Constants.ADAPTIVE_PERCENTAGE_OF_ERROR;
                end
                folderNameEnd = [Constants.ADAPTIVE_FEM_TITLE_WITH_DASH, Constants.LEFT_SLASH, percentageOfErrorTypeString];
            end
            % create the folder to save results
            folderName = [Constants.FOLDER_ROOT, Constants.LEFT_SLASH,...
                Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError), Constants.LEFT_SLASH, folderNameEnd];
            [~, ~, ~] = mkdir(folderName);
            folderPath = [pwd, Constants.LEFT_SLASH, folderName, Constants.LEFT_SLASH];
        end
        
        % creates and returns a folder based on the input
        function folderPath = createFolderPath(minimumBoundaryOfAPosterioriError)
            % create the folder to save results
            folderName = [Constants.FOLDER_ROOT, Constants.LEFT_SLASH,...
                Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError)];
            [~, ~, ~] = mkdir(folderName);
            folderPath = [pwd, Constants.LEFT_SLASH, folderName, Constants.LEFT_SLASH];
        end
    end
end









