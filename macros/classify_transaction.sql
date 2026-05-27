{% macro classify_transaction(amount_column) %}
    case
        when {{ amount_column }} <= 1000 then 'Low Value'
        when {{ amount_column }} > 1000 and {{ amount_column }} <= 10000 then 'Medium Value'
        when {{ amount_column }} > 10000 and {{ amount_column }} <= 100000 then 'High Value'
        else 'Ultra High Value (Audit Review Required)'
    end
{% endmacro %}