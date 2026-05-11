classdef tInfodist < matlab.unittest.TestCase
    %TINFODIST Tests for infodist.

    methods ( TestMethodSetup )

        function setSeed( testCase )

            s = rng();
            testCase.addTeardown( @() rng( s ) )
            rng( "default" )

        end % setSeed

    end % methods ( TestMethodSetup )

    methods ( Test )

        function tInfodistIsNearOneForIndependentUniforms( testCase )

            % Generate independent U(0, 1) random samples.
            n = 1000;
            X = rand( n, 1 );
            Y = rand( n, 1 );

            % Evaluate the information distance.
            d = infodist( X, Y );

            testCase.verifyGreaterThanOrEqual( d, 0, ...
                "The information distance was not nonnegative." )
            testCase.verifyEqual( d, 1, "The information " + ...
                "distance was not close to 1 for two independent " + ...
                "variables.", "AbsTol", 1e-3 )

        end % tInfodistIsNearOneForIndependentUniforms

        function tInfodistIsNearZeroForDependentVariables( testCase )

            % Generate X~N(0, 1) and Y~3*X with some additive noise of very
            % small variance.
            n = 1000;
            X = randn( n, 1 );
            Y = 3 * X + 0.001 * randn( n, 1 );

            % Evaluate the information distance.
            d = infodist( X, Y );

            testCase.verifyGreaterThanOrEqual( d, 0, ...
                "The information distance was not nonnegative." )
            testCase.verifyLessThan( d, 0.2, "The information " + ...
                "distance was not small for almost linearly " + ...
                "dependent random variables." )

        end % tInfodistIsNearZeroForDependentVariables

        function tIdenticalVariablesHaveZeroInformationDistance( testCase )

            % Evaluate the information distance between two identical
            % random variables.
            n = 1000;
            X = randn( n, 1 );
            Y = X;
            d = infodist( X, Y );

            testCase.verifyGreaterThanOrEqual( d, 0, ...
                "The information distance was not nonnegative." )
            testCase.verifyLessThan( d, 0.2, "The information " + ...
                "distance was not very close to zero for identical " + ...
                "random variables." )

        end % tIdenticalVariablesHaveZeroInformationDistance

        function tConstantInputFiniteOutput( testCase )

            % Evaluate the information distance between two constant
            % random variables.
            U = ones( 100, 1 );
            X = 2 * U;
            Y = 5 * U;
            d = infodist( X, Y );

            testCase.verifyGreaterThanOrEqual( d, 0, ...
                "The information distance was not nonnegative." )
            testCase.verifyTrue( isfinite( d ), ...
                "The information distance between two constant " + ...
                "random variables was not well-defined." )

        end % tConstantInputFiniteOutput

    end % methods ( Test )

end % classdef