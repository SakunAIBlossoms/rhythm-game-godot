extends Node

func ParseCustomChart(data:String):
	var eachnote = data.split("|", false)
	
	var finalchartdata = {}
	
	var outerid = -1
	for note in eachnote:
		outerid += 1
		print(note)
		var rawnoteinfo = note.split(":")
		var id = -1
		var finalnote = {}
		for value in rawnoteinfo:
			id += 1
			print("value")
			match(id):
				0: finalnote.set("time", value)
				1: finalnote.set("lane", value)
				2: finalnote.set("type", value)
				3: finalnote.set("hitsound", value)
				_: print("Value for id number "+str(id)+" cannot be interpreted, the value is ["+str(value)+"]")
		
		print("Completed parsing note "+str(outerid))
		finalchartdata.set(outerid, finalnote)
	return finalchartdata
