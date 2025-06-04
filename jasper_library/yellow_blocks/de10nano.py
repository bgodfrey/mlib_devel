from .yellow_block import YellowBlock
from clk_factors import clk_factors
from constraints import ClockConstraint, ClockGroupConstraint, PortConstraint, RawConstraint


class de10nano(YellowBlock):
    def initialize(self):

        self.pl_clk_mhz = self.blk['pl_clk_rate']
        self.T_pl_clk_ns = 1.0/self.pl_clk_mhz*1000


        self.provides.append('sys_clk')
        self.provides.append('sys_rst')


    def modify_top(self, top):
        top.assign_signal('sys_clk', 'sys_clk')
        top.assign_signal('sys_rst', 'sys_rst')



    def gen_children(self):
        
        return []


    def gen_constraints(self):
        cons = []
        cons.append(ClockConstraint('FPGA_CLK1_50', 'sys_clk', period=self.T_pl_clk_ns, port_en=True, virtual_en=False))
        cons.append(PortConstraint('FPGA_CLK1_50', 'sys_clk', iogroup_index=[0], port_index=[0]))
        return cons


    def gen_tcl_cmds(self):    
        return {}