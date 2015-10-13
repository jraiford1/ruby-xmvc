module GMVCApp
  class BrowserController < GMVC::Controller
    def on_btn_clear_clicked
      @model['entry'] = '0.0'
    end
  end
end
