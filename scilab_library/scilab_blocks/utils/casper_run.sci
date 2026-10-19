// In this function, we run a shell command and raise an error if it fails.
// It replaces unix_s/unix_w, which Scilab removed in 2027.0.0. host() works in all
// supported versions; the command's output goes to the terminal that started Scilab.
function [] = casper_run(cmd)
    status = host(cmd);
    if status <> 0 then
        error(msprintf('Command failed with exit code %d: %s', status, cmd));
    end
endfunction
