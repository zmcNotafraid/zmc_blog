# -*- encoding : utf-8 -*-
Refinery::Core::Engine.routes.append do
  match '/refinery/*path' => 'admin/base#error_404'
end
