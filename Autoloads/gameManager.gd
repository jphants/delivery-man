extends Node

var tasks: Array[String] = []

signal task_added(task_id: String)
signal task_completed(task_id: String)

func add_task(task_id: String) -> void:
	if task_id in tasks:
		return
	tasks.append(task_id)
	emit_signal("task_added", task_id)


func complete_task(task_id: String) -> void:
	if task_id not in tasks:
		return
	tasks.erase(task_id)
	emit_signal("task_completed", task_id)
