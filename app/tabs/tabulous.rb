Tabulous.setup do

  tabs do

    profile_tab do
      text          { 'Profile' }
      link_path     { '/profile/showVid' }
      visible_when  { true }
      enabled_when  { true }
      active_when   { a_subtab_is_active }
      #active_when   { in_action('any').of_controller('profile') }
    end
    
    video_subtab do
      text          { 'Videos' }
      link_path     { '/profile/showVid' }
      visible_when  { true }
      enabled_when  { true }
      active_when   { in_actions('showVid' , 'showSingleVid', 'addVid').of_controller('profile') }
    end
    
    audio_subtab do
      text {'Audio'}
      link_path {'/profile/showAud'}
      visible_when {true}
      enabled_when {true}
      active_when {in_action('showAud').of_controller('profile')}
    end
    
    messages_tab do
      text          { 'Messages' }
      link_path     { '/profile/showAllMessage' }
      visible_when  { true }
      enabled_when  { true }
      active_when   { in_action('showAllMessage').of_controller('profile') }
    end
    
    

  end
  
  

  customize do

    # which class to use to generate HTML
    # :default, :html5, :bootstrap, :bootstrap_pill or :bootstrap_navbar
    # or create your own renderer class and reference it here
    # renderer :default
    renderer :bootstrap
    # whether to allow the active tab to be clicked
    # defaults to true
    # active_tab_clickable true

    # what to do when there is no active tab for the current controller action
    # :render -- draw the tabset, even though no tab is active
    # :do_not_render -- do not draw the tabset
    # :raise_error -- raise an error
    # defaults to :do_not_render
    # when_action_has_no_tab :do_not_render

    # whether to always add the HTML markup for subtabs, even if empty
    # defaults to false
    # render_subtabs_when_empty false

  end

  # The following will insert some CSS straight into your HTML so that you
  # can quickly prototype an app with halfway-decent looking tabs.
  #
  # This scaffolding should be turned off and replaced by your own custom
  # CSS before using tabulous in production.
  use_css_scaffolding do
    background_color '#AE9C96'
    text_color '#444'
    active_tab_color '#FFFFFF'
    hover_tab_color '#ddd'
    inactive_tab_color '#E6E6E6'
    inactive_text_color '#888'
  end

end
