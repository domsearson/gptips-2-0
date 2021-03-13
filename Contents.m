% GPTIPS2
% Symbolic Data Mining for MATLAB
% (c) Dominic Searson 2009-2015
%
% Files
%   add3                          - Node. Ternary addition function.
%   bootsample                    - Get an index vector to sample with replacement a data matrix X.
%   comparemodelsREC              - Graphical REC performance curves for between 1 and 5 multigene models.
%   crossover                     - Sub-tree crossover of encoded tree expressions to produce 2 new ones.
%   cube                          - Node. Calculates the element by element cube of a vector.
%   cubic_config                  - Config file for multigene regression on a simple cubic polynomial.
%   displaystats                  - Displays run stats periodically.
%   drawtrees                     - Draws the tree structure(s) of an individual in a web browser.
%   evalfitness                   - Calls the user specified fitness function.
%   evalfitness_par               - Calls the user specified fitness function (parallel version).
%   extract                       - Extract a subtree from an encoded tree expression.
%   gauss                         - Node. Gaussian function of input.
%   genebrowser                   - Visually analyse unique genes in a population and identify horizontal bloat.
%   genefilter                    - Removes highly correlated genes from a unique GENES struct.
%   genes2gpmodel                 - Create a data structure representing a multigene symbolic regression model from the specified gene list.
%   getcomplexity                 - Returns the expressional complexity of an encoded tree or a cell array of trees.
%   getdepth                      - Returns the tree depth of an encoded tree expression.
%   getnumnodes                   - Returns the number of nodes in an encoded tree expression or the total node count for a cell array of expressions.
%   gp_2d_mesh                    - Creates new training matrix containing pairwise values of all x1 and x2.
%   gp_userfcn                    - Calls a user defined function once per generation if one has been specified in the field GP.USERDATA.USER_FCN.
%   gpand                         - Node. Wrapper for logical AND
%   gpcheck                       - Perform pre-run error checks.
%   gpdefaults                    - Initialises the GPTIPS struct by creating default parameter values.
%   gpdemo1                       - GPTIPS 2 demo of simple symbolic regression on Koza's quartic polynomial.
%   gpdemo1_config                - Config file demonstrating simple (naive) symbolic regression.
%   gpdemo2                       - GPTIPS 2 demo of multigene regression on a non-linear function.
%   gpdemo2_config                - Config for multigene symbolic regression on data (y) generated from a non-linear function of 4 inputs (x1, x2, x3, x4).
%   gpdemo3                       - GPTIPS 2 demo of multigene symbolic regression on non-linear simulated pH data.
%   gpdemo3_config                - Config file demonstrating multigene symbolic regression on data from a simulated pH neutralisation process.
%   gpdemo4                       - GPTIPS 2 demo of multigene symbolic regression on a concrete compressive strength data set.
%   gpdemo4_config                - Config file demonstrating feature selection with multigene symbolic regression.
%   gpfinalise                    - Finalises a run.
%   gpinit                        - Initialises a run.
%   gpinitparallel                - Initialise the Parallel Computing Toolbox.
%   gpmodel2func                  - Converts a multigene symbolic regression model to an anonymous function and returns the function handle.
%   gpmodel2mfile                 - Converts a multigene regression model to a standalone M file.
%   gpmodel2struct                - Create a struct describing a multigene regression model.
%   gpmodel2sym                   - Create a simplified Symbolic Math object for a multigene symbolic regression model.
%   gpmodelfilter                 - Object to filter a population of multigene symbolic regression models.
%   gpmodelgenes2mfile            - Converts individual genes of a multigene symbolic regression model to a standalone M file.
%   gpmodelreport                 - Generate an HTML report on the specified multigene regression model.
%   gpmodelvars                   - Display the frequency of input variables present in the specified model.
%   gpnot                         - Node. Wrapper for logical NOT 
%   gpor                          - Node. Wrapper for logical or
%   gppopvars                     - Display frequency of the input variables present in models in the population.
%   gppretty                      - Simplify and prettify a multigene symbolic regression model.
%   gprandom                      - Sets random number generator seed according to system clock or user seed.
%   gpreformat                    - Reformats encoded trees so that the Symbolic Math toolbox can process them properly.
%   gpsimplify                    - Simplify SYM expressions in a less glitchy way than SIMPLIFY or SIMPLE.
%   gpterminate                   - Check for early termination of run.
%   gptic                         - Updates the running time of this run.
%   gptoc                         - Updates the running time of this run.
%   gptoolboxcheck                - Checks if certain toolboxes are installed and licensed.
%   gptreestructure               - Create cell array containing tree structure connectivity and label information for an encoded tree expression.
%   gth                           - Node. Greater than operator
%   HTMLequation                  - Returns an HTML formatted multigene regression model equation.
%   iflte                         - Node. Performs an element wise IF THEN ELSE operation on vectors and scalars.
%   initbuild                     - Generate an initial population of GP individuals.
%   kogene                        - Knock out genes from a cell array of tree expressions.
%   lth                           - Node. Less than operator
%   maxx                          - Node. Returns the maximum of x1 and x2.
%   mergegp                       - Merges two GP population structs into a new one.
%   minx                          - Node. Returns the minimum of x1 and x2.
%   mult3                         - Node. Ternary multiplication function.
%   mutate                        - Mutate an encoded symbolic tree expression.
%   ndfsort_rank1                 - Fast non dominated sorting algorithm for 2 objectives only - returns only rank 1 solutions.
%   neg                           - Node. Returns -1 times the argument.
%   negexp                        - Node. Calculate exp(-x) on an element by element basis. 
%   paretoreport                  - Generate an HTML performance/complexity report on the Pareto front of the population.
%   pdiv                          - Node. Performs a protected element by element divide.
%   picknode                      - Select a node (or nodes) of specified type from an encoded GP expression and return its position.
%   plog                          - Node. Calculate the element by element protected natural log of a vector. 
%   popbrowser                    - Visually browse complexity and performance characteristics of a population.
%   popbuild                      - Build next population of individuals.
%   pref2inf                      - Recursively extract arguments from a prefix expression and convert to infix where possible.
%   processOrgChartJS             - Writes Google org chart JavaScript for genes to an existing HTML file.
%   psqroot                       - Node. Computes element by element protected square root of a vector
%   quartic_fitfun                - Fitness function for simple ("naive") symbolic regression on the quartic polynomial y = x + x^2 + x^3 + x^4. 
%   regressionErrorCharacteristic - Generates REC curve data using actual and predicted output vectors.
%   regressmulti_fitfun           - Fitness function for multigene symbolic regression.
%   regressmulti_fitfun_validate  - Evaluate current 'best' multigene regression model on validation data set.
%   ripple_config                 - Config file for multigene regression on the 2D Ripple function.
%   rungp                         - Runs GPTIPS 2 using the specified configuration file.
%   runtree                       - Run the fitness function on an individual in the current population.
%   salustowicz1d_config          - Multigene regression config for one dimensional Salustowicz function.
%   scangenes                     - Scan a single multigene individual for all input variables and return a frequency vector.
%   selection                     - Selects an individual from the current population.
%   square                        - Node. Calculates the element by element square of a vector or matrix
%   standaloneModelStats          - Compute model performance stats for actual and predicted values.
%   step                          - Node. Threshold function that returns 1 if the argument is >= 0 and 0 otherwise.
%   summary                       - Plots basic summary information from a run.
%   thresh                        - Node. Threshold function that returns 1 if the first argument is >= to the second argument and returns 0 otherwise.
%   tree2evalstr                  - Converts encoded tree expressions into math expressions that MATLAB can evaluate directly.
%   treegen                       - Generate a new encoded GP tree expression.
%   uball_config                  - Multigene regression config for the n dimensional Unwrapped Ball function.
%   uniquegenes                   - Returns a GENES structure containing the unique genes in a population.
%   updatestats                   - Update run statistics.
