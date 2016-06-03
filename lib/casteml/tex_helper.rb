module Casteml
	module TexHelper
	    autoload(:OverPic, 'casteml/tex_helper/over_pic.rb')

	    def tiny(content)
	      "\\tiny{#{content}}"      
	    end
	    
	    def footnotesize(content)
	      "\\footnotesize{#{content}}"
	    end
	    
	    def scriptsize(content)
	      "\\scriptsize{#{content}}"
	    end

	    def normalsize(content)
	      "\\normalsize{#{content}}"
	    end

	    def large(content)
	      "\\large{#{content}}"
	    end

	    def Large(content)
	      "\\Large{#{content}}"
	    end

	    def LARGE(content)
	      "\\LARGE{#{content}}"
	    end
	    
	    def huge(content)
	      "\\huge{#{content}}"
	    end
	    
	    def Huge(content)
	      "\\Huge{#{content}}"
	    end		

	end
end
