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
                testCase.verifyTrue( true )
            catch e
                testCase.verifyTrue( false, ...
                    "The main example script did not run " + ...
                    "without errors." )
            end % try/catch

        end % tScriptIsWarningFree

    end % methods ( Test )

end % classdef