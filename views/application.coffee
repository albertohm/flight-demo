$(document).ready ->

  prepareForm = ->
    query = "START n=node:node_auto_index(type='Airport')
    RETURN n.name as Name, n.country as Country, n.iata_faa as Code;"
    $.ajax(
      url: "/api/v1/launch_cypher"
      type: "POST"
      data: { query }
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
      fromCity = $('input#fromSelect').val().split(' - ')[0]
      toCity = $('input#toSelect').val().split(' - ')[0]

      query = "START from_air=node:node_auto_index(name='Gran Canaria'),
      to_air=node:node_auto_index(name='Barcelona')
      MATCH  p=(from_air)-[:VIA|TO*2..4]->(to_air)
      WITH (length(rels(p))/2-1) AS Stops, from_air, to_air, FILTER(x in p: has(x.airline)) as raw_routes,
      FILTER(x in TAIL(p): has(x.name)) AS raw_airports
      RETURN from_air.name AS From, extract(n in raw_airports : n.name) as Airports,
      extract(n in raw_routes : n.airline) as Route,
      to_air.name AS To, Stops ORDER BY Stops LIMIT 50;"

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
