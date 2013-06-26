$(document).ready ->

  prepareForm = ->
    query = "START n=node(*) WHERE has(n.type) AND n.type = 'Airport' RETURN n.name ORDER BY n.name ASC;"
    $.ajax(
      url: "/api/v1/launch_cypher"
      type: "POST"
      data: { query }
      dataType: 'json',
      success: (data) ->
        resultList = data.result.data.map( (item) -> item[0])
        $("#fromSelect, #toSelect").typeahead(
          source: resultList#data.result.data
        )
        $('button#search').removeAttr('disabled')

      error: (response) -> alert "Some error"
    )

    $('button#search').click ->
      $('table#result').find('tr').remove()
      fromCity = $('input#fromSelect').val()
      toCity = $('input#toSelect').val()

      query = "START from_city=node:node_auto_index(name='#{fromCity}'),to_city=node:node_auto_index(name='#{toCity}')
      MATCH  (r)-[:ORIGIN]->(from_airport)-[:LOCATED_NEAR]->(from_city),
        (r)-[:DESTINATION]->(to_airport)-[:LOCATED_NEAR]->(to_city), (r)-[:`WITH`]->(airline)
        RETURN from_airport.name, to_airport.name, r.airline, airline.name, r.stops
        LIMIT 100"

      $.ajax(
        url: "/api/v1/launch_cypher"
        type: "POST"
        data: { query }
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
