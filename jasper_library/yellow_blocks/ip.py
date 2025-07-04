from .yellow_block import YellowBlock

class ip(YellowBlock):
    def initialize(self):
        module_name = self.ip_name
        if self.platform.manufacturer.lower() != 'intel':
            module_name += '_ip'
        self.ips = [{'path':self.lib_path, 
                     'name':self.ip_name,
                     'module_name':module_name,
                     'vendor':'User_Company',
                     'library':'SysGen',
                     'version':'1.0',
                     }]
        
