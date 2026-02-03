import os

from django.shortcuts import render, redirect, get_object_or_404

from .models import Task

MOUNT_PATH = '/mnt/host-data'


def task_list(request):
    if request.method == 'POST':
        title = request.POST.get('title', '').strip()
        if title:
            Task.objects.create(title=title)
        return redirect('task_list')
    tasks = Task.objects.order_by('-created_at')
    host_mount_active = os.path.ismount(MOUNT_PATH)
    return render(request, 'todos/task_list.html', {
        'tasks': tasks,
        'host_mount_active': host_mount_active,
    })


def toggle_task(request, pk):
    task = get_object_or_404(Task, pk=pk)
    task.completed = not task.completed
    task.save()
    return redirect('task_list')


def delete_task(request, pk):
    task = get_object_or_404(Task, pk=pk)
    task.delete()
    return redirect('task_list')
