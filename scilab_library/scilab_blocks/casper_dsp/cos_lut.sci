// Coherent cosine-wave source for hardware FFT debugging.
function [x, y, typ]= cos_lut(job, arg1, arg2)
    x=[];y=[];typ=[];
    blkname = 'cos_lut';
    output_width = 16;
    fft_length = 1024;
    tone_bin = 1;
    amplitude = 12000;
    select job
      case 'set' then
        x=arg1;
        graphics = arg1.graphics;
        exprs = graphics.exprs;
        model = arg1.model;
        txt = [ 'Block Name (any string)';...
                'Output bit width';...
                'FFT length';...
                'Tone bin';...
                'Amplitude';];
        [ok, blkname, output_width, fft_length, tone_bin, amplitude, exprs] = scicos_getvalue("Set cos_lut block parameters",...
                          txt,...
                          list("str", 1, "str",1, "str",1, "str",1, "str",1),...
                          exprs);
        if ok then
            output_width = strtod(output_width);
            fft_length = strtod(fft_length);
            tone_bin = strtod(tone_bin);
            amplitude = strtod(amplitude);
            graphics.in_label = ['rst', 'en'];
            graphics.out_label = ['out'];
            graphics.style = 'shape=rectangle;fillColor=grey';
            graphics.exprs = exprs;
            x.graphics = graphics;
            model.in = [1 2];
            model.in2 = [1, 1];
            model.out = [1];
            model.out2 = [output_width];
            x.model = model;
        end
      case 'define' then
        model = scicos_model();
        model.sim = list('cos_lut',4);
        model.blocktype = 'c';
        model.rpar = [0, 3, 4, 5, 6];
        model.in = [1 2];
        model.in2 = [1, 1];
        model.out = [1];
        model.out2 = [16];
        exprs = ['cos_lut'; '16'; '1024'; '1'; '12000'];
        gr_i = [];
        model.label = "dsp";
        x=standard_define([5 4],model,exprs,gr_i)
        x.graphics.out_label = ['out'];
        x.graphics.in_label = ['rst', 'en'];
        x.graphics.style = 'shape=rectangle;fillColor=grey';
        debug_info('cos_lut loaded...')
    end
  endfunction
