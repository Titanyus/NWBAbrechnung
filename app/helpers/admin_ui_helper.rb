module AdminUiHelper
  def ui_date(value, empty: "–")
    value ? value.strftime("%d.%m.%Y") : empty
  end

  def ui_timestamp(value)
    value.in_time_zone.strftime("%d.%m.%Y %H:%M")
  end

  def ui_decimal(value)
    number_with_delimiter(value.to_s("F"), delimiter: ".", separator: ",")
  end

  def ui_status(label, tone: :neutral)
    tag.span(label, class: "status status--#{tone}")
  end

  def ui_field(full: false, required: false, &block)
    content = capture(&block)
    tag.div(class: [ "field", ("field--full" if full) ].compact.join(" ")) do
      safe_join([ (tag.span("Pflichtfeld", class: "field-required") if required), content ].compact)
    end
  end
  def ui_context_options
    @contract_context ? { contract_id: @contract_context.id } : {}
  end
  def ui_shell_plant
    @plant if @plant&.persisted?
  end

  def ui_search_data(frame)
    { live_search: true, turbo_frame: frame }
  end
  def ui_body_data
    { controller: "theme live-search", action: "input->live-search#input change->live-search#change compositionend->live-search#input turbo:before-fetch-request->live-search#request turbo:before-fetch-response->live-search#response turbo:before-frame-render->live-search#beforeRender turbo:frame-render->live-search#afterRender" }
  end
end
