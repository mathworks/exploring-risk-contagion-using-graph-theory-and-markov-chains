classdef tRiskContagion < matlab.unittest.TestCase
    %TRISKCONTAGION Check the main example script.

    methods ( TestClassSetup )

        function filterTestOnCI( testCase )

            ci = getenv( "GITHUB_ACTIONS" ) == "true";
            testCase.assumeFalse( ci, ...
                "This test only runs locally, not in CI systems." )

        end % filterTestOnCI

    end % methods ( TestClassSetup )

    methods ( Test )

        function tScriptIsWarningFree( testCase )

            try
                RiskContagion
                success = true;
            catch
                success = false;
            end % try/catch
            
            testCase.verifyTrue( success, ...
                "The main example script did not run " + ...
                "without errors." )

        end % tScriptIsWarningFree

    end % methods ( Test )

end % classdef