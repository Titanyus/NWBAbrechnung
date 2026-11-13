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
end
