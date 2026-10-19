from .dsp_block import DSPBlock


class cos_lut(DSPBlock):
    def initialize(self):
        self.add_source('cos_lut/*')

    def modify_top(self, top):
        self._populate_parent_ports(top)

        output_width = int(self.output_width)
        if output_width < 1 or output_width > 32:
            raise RuntimeError("cos_lut output_width must be in the range 1..32")

        module = 'cos_lut'
        inst = top.get_instance(entity=module, name=self.fullname)

        inst.add_parameter("OUTPUT_WIDTH", "32'd%d" % output_width)
        inst.add_parameter("FFT_LENGTH", "32'd%d" % int(self.fft_length))
        inst.add_parameter("TONE_BIN", "32'd%d" % int(self.tone_bin))
        inst.add_parameter("AMPLITUDE", "32'sd%d" % int(self.amplitude))

        inst.add_port('clk', 'user_clk', dir='in')
        inst.add_port('rst', self.fullname + '_rst', parent_port=False, width=1, dir='in')
        inst.add_port('en', self.fullname + '_en', parent_port=False, width=1, dir='in')
        inst.add_port(
            'out',
            self.fullname + '_out',
            parent_port=False,
            width=output_width,
            dir='out',
        )
