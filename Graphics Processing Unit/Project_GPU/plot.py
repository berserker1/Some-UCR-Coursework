import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

def read_matrices_from_file(file_path):
    matrices = []
    with open(file_path, 'r') as file:
        for line in file:
            matrix = [list(map(int, row.split())) for row in line.strip().split(';')]
            matrices.append(np.array(matrix))
    return matrices

def update_plot(frame, matrices, img_plot):
    img_plot.set_array(matrices[frame])
    return [img_plot]

def plot_matrices_as_gif(matrices, interval, output_file='output.gif'):
    fig, ax = plt.subplots(figsize=(15,15))
    ax.set_xticks([])
    ax.set_yticks([])
    img_plot = ax.imshow(matrices[0], cmap='binary', animated=True)

    ani = animation.FuncAnimation(fig, update_plot, frames=len(matrices),fargs=(matrices, img_plot), interval=interval, blit=True)

    ani.save(output_file, writer='pillow')
    plt.show()

file_path = r"file_path"
matrices = read_matrices_from_file(file_path)
plot_matrices_as_gif(matrices, interval=500, output_file='output.gif')
