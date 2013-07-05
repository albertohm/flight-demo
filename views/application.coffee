$(document).ready ->

  prepareForm = ->
    $.ajax(
      url: "/api/v1/prepare_selects"
      type: "GET"
      dataType: 'json',
      success: (data) ->
        resultList = data.result.data.map( (item) ->
          item.join(' - ')
        )
        $("#fromSelect, #toSelect").typeahead(
          source: resultList#data.result.data
        )
        $('button#search').removeAttr('disabled')

      error: (response) -> alert "Some error"
    )

    $('button#search').click ->
      $('table#result').find('tr').remove()
      fromAirport = $('input#fromSelect').val().split(' - ')[0]
      toAirport = $('input#toSelect').val().split(' - ')[0]

      $.ajax(
        url: "/api/v1/search_airports"
        type: "POST"
        data: { from: fromAirport, to: toAirport }
        success: (data) ->

          table = $('table#result')
          header = $('<tr></tr>').addClass('header')

          for headerField in data.result.columns
            header.append($('<th></th>').text(headerField))

          table.append(header)

          for result in data.result.data
            row = $('<tr></tr>')
            for rowData in result
              row.append $('<td></td>').text(rowData)
            table.append(row)

        error: (response) -> alert "Some error"
      )

  prepareForm()
