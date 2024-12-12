
procedure aggregateTables
  @getSettings

  beginPause: "Set Parameters"
    comment: "How many sections should signal be divided into? 1 returns the overall aggregated value. 3 returns"
    comment: "aggregated results for the first third, midle third, and final third, and so on."
    optionMenu: "Number of formants:", number_of_formants
  			option: "3"
  			option: "4"
        option: "5"
    optionMenu: "Number of bins:", number_of_bins
  			option: "1"
  			option: "3"
  			option: "5"
        option: "7"
        option: "9"
        option: "10"
    	optionMenu: "Statistic", 1
  	        option: "median"
  					option: "mean"
  nocheck endPause: "Ok", 1

  @saveSettings

  number_of_bins = number(number_of_bins$)
  number_of_formants = number(number_of_formants$)

  Create Table with column names: "output", size(tables#), "file f0 duration number label group color"
  .output = selected ("Table")

  for j from 1 to number_of_bins
    for i from 1 to number_of_formants
      Append column: "f"+string$(i)+string$(j)
    endfor
  endfor

  for .iii from 1 to size(tables#)
    .tbl = tables# [.iii]
    selectObject: .tbl
    .nframes = Get number of rows
    Append column: "ntime"
    for .j from 1 to .nframes
      tmp = .j / (.nframes/number_of_bins)
      Set numeric value: .j, "ntime", ceiling( tmp )
    endfor

    selectObject: .tbl
    .firstFrameTime = Get value: 1, "time"
    .lastFrameTime = Get value: .nframes, "time"
    .duration = .lastFrameTime - .firstFrameTime
    .duration = round(.duration * 1000) / 1000

    selectObject: .output
    Set numeric value: .iii, "duration", .duration

    selectObject: .tbl
    .mf0 = Get mean: "f0"

    if .mf0 > 0
      .tmp_tbl = Extract rows where column (number): "f0", "greater than", 0
      .mf0 = Get mean: "f0"
      .mf0 = round(.mf0 * 10) / 10
      removeObject: .tmp_tbl
    endif    
    selectObject: .output
    Set numeric value: .iii, "f0", .mf0

    # label, group, column, number

    Set numeric value: .iii, "number", .iii
    Set string value: .iii, "label", "*"
    Set numeric value: .iii, "group", 1
    Set string value: .iii, "color", "Blue"


    for .j from 1 to number_of_bins
      selectObject: .tbl
      .tmp_tbl = Extract rows where column (number): "ntime", "equal to", .j
      for .k from 1 to number_of_formants
        if statistic == 2
          .mf'.k''.j' = Get mean: "f"+string$(.k)
        endif
        if statistic == 1
          .mf'.k''.j' = Get quantile: "f"+string$(.k), 0.5
        endif
      endfor
      removeObject: .tmp_tbl
    endfor

    selectObject: .tbl
    name$ = selected$ ("Table")
    selectObject: .output
    Set string value... .iii file 'name$'
    for .j from 1 to number_of_bins
      for .i from 1 to number_of_formants
        Set numeric value... .iii f'.i''.j' round(.mf'.i''.j')
      endfor
    endfor

  endfor
  selectObject: .output
  #Save as comma-separated file: folder$ + "/processed_data/aggregated_data.csv"
  Rename: "aggregated"
endproc
