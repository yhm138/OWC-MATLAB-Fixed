function run_all_fixed(pattern, figdir)
% RUN_ALL_FIXED  Run every Chapter*/FIXED_*.m script and (optionally) save
%   its figures as PNG files. Works in MATLAB (no toolboxes needed) and in
%   GNU Octave (>= 6).
%
%   run_all_fixed                      % run all FIXED scripts
%   run_all_fixed('Chapter4/FIXED_*')  % run a subset
%   run_all_fixed('', 'docs/figures')  % run all and save figures
%
%   Headless Octave:  xvfb-run -a octave --no-gui --eval "run_all_fixed('', 'docs/figures')"
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'util'));
if nargin < 1 || isempty(pattern)
    pattern = 'Chapter*/FIXED_*.m';
end
if nargin < 2
    figdir = '';
end
[pdir, pname, pext] = fileparts(pattern);
chapters = dir(fullfile(root, pdir));
chapters = chapters([chapters.isdir]);
files = {};
for c = 1:numel(chapters)
    if chapters(c).name(1) == '.', continue; end
    d = dir(fullfile(root, chapters(c).name, [pname pext]));
    for k = 1:numel(d)
        files{end+1} = fullfile(root, chapters(c).name, d(k).name); %#ok<AGROW>
    end
end
if isempty(files)   % pattern without wildcard directory, e.g. 'Chapter4/FIXED_*'
    d = dir(fullfile(root, pattern));
    for k = 1:numel(d)
        files{end+1} = fullfile(d(k).folder, d(k).name); %#ok<AGROW>
    end
end
if ~isempty(figdir) && ~exist(fullfile(root, figdir), 'dir')
    mkdir(fullfile(root, figdir));
end
set(0, 'DefaultFigureVisible', 'off');
if exist('OCTAVE_VERSION', 'builtin')
    warning('off', 'Octave:negative-data-log-axis');
end
status = cell(numel(files), 2);
for k = 1:numel(files)
    [~, name] = fileparts(files{k});
    fprintf('\n===== %s =====\n', name);
    t0 = tic;
    ok = run_one(files{k});
    status(k,:) = {name, ok};
    if ok && ~isempty(figdir)
        figs = findall(0, 'type', 'figure');
        for n = 1:numel(figs)
            fn = fullfile(root, figdir, sprintf('%s_%d.png', name, n));
            print(figs(n), '-dpng', '-r90', fn);
        end
    end
    close all;
    fprintf('----- %s: %s (%.1f s)\n', name, ternary(ok, 'OK', 'FAILED'), toc(t0));
end
fprintf('\nSummary:\n');
for k = 1:size(status, 1)
    fprintf('  %-45s %s\n', status{k,1}, ternary(status{k,2}, 'OK', 'FAILED'));
end
end

function ok = run_one(file)
% run in a separate workspace so that "clear" inside the scripts is harmless
try
    run(file);
    ok = true;          % assigned after run(): the scripts call "clear"
catch err
    ok = false;
    fprintf(2, 'ERROR: %s\n', err.message);
end
end

function s = ternary(c, a, b)
if c, s = a; else, s = b; end
end
