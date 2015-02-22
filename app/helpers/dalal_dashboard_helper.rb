module DalalDashboardHelper

  def gapper
    if @gap == 3
       @link = @link+"..."
       @gap = 1
    else
       @gap = @gap + 1
    end
  end
  
  def mojo_paginator(count,type=nil,active = 0)
  	@link = ""
    @gap = 1
    active = active.to_i
      
      if active != 0
       @link = @link.to_s+"<a href='#paginator' onclick=update_modal_partials('#{active-1}','#{type}');> << </a>"
      end
      # @link = @link.to_s+"<a href='#paginator' onclick=update_modal_partials('0','#{type}');> 0 </a>"
      # @link = @link.to_s+"<a href='#paginator' onclick=update_modal_partials('1','#{type}');> 1 </a>"
        count.to_i.times do |i|
          if (active == i || active+1 == i || active+2 == i) && (active!=0 || active!=1 || active!=2 )
           @link = @link.to_s+"<a href='#paginator' onclick=update_modal_partials('#{i}','#{type}');> #{i} </a>"
           gapper   
          elsif (count+active)/2 == i || (count+active)/2-1 == i || (count+active)/2+1 == i 
           @link = @link.to_s+"<a href='#paginator' onclick=update_modal_partials('#{i}','#{type}');> #{i} </a>"
           gapper
          elsif count == i || count-1 == i || count-2 == i
           @link = @link.to_s+"<a href='#paginator' onclick=update_modal_partials('#{i}','#{type}');> #{i} </a>"
           gapper
          else
           @link = @link
          end
        end
      if !(active > count-4 && active <= count+1)        
       @link = @link.to_s+"<a href='#paginator' onclick=update_modal_partials('#{active+1}','#{type}');> >> </a>"
      end

        return @link.html_safe
  end

end
