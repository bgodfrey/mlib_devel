from .yellow_block import YellowBlock
from memory import Register
from .yellow_block_typecodes import *

class sys_block_intel(YellowBlock):
	def initialize(self):
		self.typecode = TYPECODE_SYSBLOCK
		#self.add_source('sys_block_intel')
		self.add_source('sys_block_counter')
		self.add_source('sys_block_intel/sys_block_counter_cdc.v')
		if not hasattr(self, 'scratchpad'): self.scratchpad = 0
		# the internal memory_map
		self.memory_map = [
			Register('board_id',   mode='r',  offset=0x0,  default_val=int(self.board_id)),
			Register('rev',        mode='r',  offset=0x4,  default_val=((int(self.rev_maj) << 16) + int(self.rev_min))),
			Register('rev_rcs',    mode='r',  offset=0xc,  default_val=int(self.rev_rcs)),
			Register('scratchpad', mode='rw', offset=0x10, default_val=int(self.scratchpad)),
			Register('clkcounter', mode='r',  offset=0x14),
		]

	def modify_top(self,top):

		
		# user_clk is driven by the platform (xsg) block

		if not top.does_signal_exist('user_rst'):
			top.add_signal('user_rst', width=0)
			top.assign_signal('user_rst', '~axil_rst_n') 

		arch = [val.lower() for val in self.platform.mmbus_architecture]
		if 'axi4-lite' in arch:
			top.add_axi4lite_interface(
				'sys',
				mode='rw',
				nbytes=32,
				memory_map=self.memory_map,
				typecode=self.typecode
			)

			# Constant read-only sys_block registers
			top.add_signal('sys_board_id_in', width=32)
			top.assign_signal('sys_board_id_in', str(self.board_id))
			top.add_signal('sys_board_id_in_we', width=1)
			top.assign_signal('sys_board_id_in_we', "1'b1")

			top.add_signal('sys_rev_in', width=32)
			top.assign_signal(
				'sys_rev_in',
				f"(({int(self.rev_maj)} & 32'hFFFF) << 16) | ({int(self.rev_min)} & 32'hFFFF)"
			)
			top.add_signal('sys_rev_in_we', width=1)
			top.assign_signal('sys_rev_in_we', "1'b1")

			top.add_signal('sys_rev_rcs_in', width=32)
			top.assign_signal('sys_rev_rcs_in', str(self.rev_rcs))
			top.add_signal('sys_rev_rcs_in_we', width=1)
			top.assign_signal('sys_rev_rcs_in_we', "1'b1")

			# Counter path
			inst = top.get_instance('sys_block_counter', 'sys_block_counter_inst')
			inst.add_parameter('DATA_WIDTH', 32)
			inst.add_port('user_clk', 'user_clk')
			inst.add_port('user_rst', 'user_rst')
			inst.add_port('en', '1')
			inst.add_port('count_out', signal='sys_clkcounter_cdc', dir='out', width=32)

			# The counter runs on user_clk and is read on axil_clk; cross in Gray code so
			# a read never sees a half-updated count when the two clocks differ
			inst = top.get_instance(entity='sys_block_counter_cdc', name='sys_block_counter_cdc_inst')
			inst.add_parameter('DATA_WIDTH', 32)
			inst.add_port('src_clk', 'user_clk')
			inst.add_port('src_count', 'sys_clkcounter_cdc', width=32)
			inst.add_port('dst_clk', 'axil_clk')
			inst.add_port('dst_count', 'sys_clkcounter_in', width=32)

			top.add_signal('sys_clkcounter_in_we', width=1)
			top.assign_signal('sys_clkcounter_in_we', "1'b1")	

		elif 'wishbone' in arch:
			self.add_source('sys_block_intel')
			inst = top.get_instance('sys_block_intel', 'sys_block_intel_inst')
			inst.add_parameter('BOARD_ID', self.board_id)
			inst.add_parameter('REV_MAJ', self.rev_maj)
			inst.add_parameter('REV_MIN', self.rev_min)
			inst.add_parameter('REV_RCS', self.rev_rcs)
			inst.add_port('user_clk', 'user_clk', parent_port=False, parent_sig=False)
			inst.add_port('IP_RESET', 'user_rst', parent_sig=False)
			inst.add_wb_interface('sys', mode='rw', nbytes=32, memory_map=self.memory_map, typecode=self.typecode)
		else:
			raise RuntimeError("Unknown memory bus architecture")
