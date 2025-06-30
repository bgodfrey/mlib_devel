from .yellow_block import YellowBlock
from clk_factors import clk_factors
from constraints import ClockConstraint, ClockGroupConstraint, PortConstraint, RawConstraint


class de10nano(YellowBlock):
    def initialize(self):

        self.name = 'de10nano'
        self.fpga = '5CSEBA6U23I7'
        self.family = 'Cyclone V'
        self.manufacturer = 'intel'
        self.project_mode = True
        
        self.pl_clk_mhz = self.blk['pl_clk_rate']
        self.T_pl_clk_ns = 1.0/self.pl_clk_mhz*1000

        self.provides.append('sys_clk')
        self.provides.append('sys_rst')

        self.provides.append('fpga_clk1_50')
        self.provides.append('fpga_clk1_5090')
        self.provides.append('fpga_clk1_50180')
        self.provides.append('fpga_clk1_50270')

    def modify_top(self, top):
        top.assign_signal('sys_clk', 'sys_clk')
        top.assign_signal('sys_rst', 'sys_rst')

    def gen_children(self):
        
        return []


    def gen_constraints(self):
        cons = []
        cons.append(ClockConstraint('fpga_clk1_50', 'fpga_clk1_50', period=self.T_pl_clk_ns, port_en=True, virtual_en=False))
        #cons.append(ClockConstraint('FPGA_CLK1_5090', 'sys_clk', period=self.T_pl_clk_ns, port_en=False, virtual_en=True))
        #cons.append(ClockConstraint('FPGA_CLK1_50180', 'sys_clk', period=self.T_pl_clk_ns, port_en=False, virtual_en=True))
        #cons.append(ClockConstraint('FPGA_CLK1_50270', 'sys_clk', period=self.T_pl_clk_ns, port_en=False, virtual_en=True))
        #cons.append(PortConstraint('fpga_clk1_50', 'fpga_clk1_50', iogroup_index=[0], port_index=[0]))
        cons.append(PortConstraint('fpga_clk1_50', 'fpga_clk1_50'))
        return cons


    def gen_tcl_cmds(self):    
        return {}