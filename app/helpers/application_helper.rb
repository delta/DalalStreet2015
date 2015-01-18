module ApplicationHelper
 
def sortable(column, title = nil)
  title ||= column.titleize
  css_class = column == params[:order] ? "fa fa-sort-"+params[:direction]  : "fa fa-sort-desc"
  direction = column == params[:order] && params[:direction] == "asc" ? "desc" : "asc"
  link_to title, params.merge(:order => column, :direction => direction,:page=>nil),{:class=> css_class}
end


end