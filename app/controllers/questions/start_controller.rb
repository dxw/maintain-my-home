module Questions
  class StartController < ApplicationController
    def index
      if params[:keep_address]
        selected_answer_store.reset_repair_questions!
      else
        reset_session
      end

      @form = StartForm.new
    end

    def submit
      @form = StartForm.new(start_form_params)

      return render :index if @form.invalid?

      next_page = page_mapping[@form.answer] || page_path('emergency_contact')
      redirect_to next_page
    end

    private

    def start_form_params
      params.require(:start_form).permit(:answer)
    end

    def page_mapping
      {
        'smell_gas' => page_path('gas'),
        'no_heating' => page_path('heating_repairs'),
        'no_water' => page_path('no_water'),
        'no_power' => page_path('no_power'),
        'exposed_wiring' => page_path('electrical_hazard_emergency'),
        'water_leak_electrics' => page_path('electrical_hazard_emergency'),
        'alarm_beeping' => page_path('alarm_beeping_emergency'),
        'none_of_the_above' => questions_path('screening_filter'),
      }
    end
  end
end
