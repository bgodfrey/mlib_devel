% --- Determine the actual top-level model system deterministically ---
% If model is a file name like 'rfsoc4x2_tut_platform.slx', bdroot(model) won't work.
% So strip extension if present.
[~, model_name, ~] = fileparts(model);
sys = model_name;

% Ensure the model is loaded
if ~bdIsLoaded(sys)
    load_system(sys);
end

fprintf('Target system is: %s\n', sys);

% --- Find Model Composer Hub block (top level of sys) ---
disp('Searching for Model Composer Hub block');
vmchub_blk = find_system(sys, ...
    'FollowLinks','on', 'LookUnderMasks','all', ...
    'SearchDepth',1, 'Tag','genX');

if numel(vmchub_blk) ~= 1
    error('Expected exactly 1 Vitis Model Composer Hub block with Tag=genX at top level of %s, found %d.', sys, numel(vmchub_blk));
end

vmchub_path = vmchub_blk{1};
vmchub = getSimulinkBlockHandle(vmchub_path);
if vmchub == -1
    error('Could not get handle for hub block: %s', vmchub_path);
end

% --- Find platform yellow block (top level of sys) ---
plat_blk = find_system(sys, ...
    'FollowLinks','on', 'LookUnderMasks','all', ...
    'SearchDepth',1, 'Tag','xps:xsg');

if numel(plat_blk) ~= 1
    error('Expected exactly 1 platform yellow block with Tag=xps:xsg at top level of %s, found %d.', sys, numel(plat_blk));
end

platform = plat_blk{1};

% --- Read platform settings ---
[~, hw_subsys] = xps_get_hw_plat(get_param(platform,'hw_sys'));
clk_rate = str2double(get_param(platform,'clk_rate'));

% --- Configure hub (use sys consistently; avoid gcs) ---
vmchub_set_param(vmchub, sys, 'SelectHardware', hw_subsys);

% Legacy HDL mode
vmchub_set_param(vmchub, sys, 'TreatDesignAsLegacyHDL', 1);

% Select subsystem (note: keep semicolon to avoid accidental command-window noise)
vmchub_set_param(vmchub, sys, 'SelectSubsystem', 1);

vmchub_set_param(vmchub, sys, 'HardwareDescription', 'VHDL');
vmchub_set_param(vmchub, sys, 'FPGAClockPeriod', num2str(1000/clk_rate));
vmchub_set_param(vmchub, sys, 'SimulinkSystemPeriod', num2str(1));
vmchub_set_param(vmchub, sys, 'ClockPinLocation', 'd7hack');

% --- Compile directory settings ---
fprintf('Setting compile directory to: %s\n', compile_dir);
export_path = [compile_dir, '/', 'sysgen'];
if exist(export_path, 'dir')
    rmdir(export_path, 's');
end

fprintf('Configuring IP settings and output directory to: %s\n', export_path);
vmchub_set_param(vmchub, sys, 'ExportDirectory', export_path);
vmchub_set_param(vmchub, sys, 'IPLibrary', 'SysGen');

RUN_IP = 1;
if RUN_IP == 1
    vmchub_set_param(vmchub, sys, 'ExportType', 'IP Catalog');
else
    vmchub_set_param(vmchub, sys, 'ExportType', 'HDL Netlist');  % <-- fixed typo
end

% --- Update diagram ---
if update == 1
    disp('Updating diagram');
    set_param(sys, 'SimulationCommand', 'update');
else
    disp('Skipping diagram update');
end

disp('Running Model Composer...');
vmc_result = vmcExport(vmchub);