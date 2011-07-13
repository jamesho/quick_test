# Include hook code here
ActiveSupport::Dependencies.load_once_paths.delete(lib_path)

#ActionView::Base.send :include, Nui::Core::GridHelper
#ActionController::Base.send :include, Nui::Core::Util
#ActionController::Base.send :include, Nui::Controller::Autocomplete
#ActionController::Base.helper Nui::Helpers::UtilHelper
