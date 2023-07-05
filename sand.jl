using Gtk
using Random

# Global variables
const rowsAmount = 100
const colsAmount = 100
const cell_size = 10
const border_size = 1
const initial_percentage = 30
const time_interval = 0.01





# Function to initialize the grid randomly
function initialize_grid()
    grid = zeros(Int8, rowsAmount, colsAmount)
    for i in 1:rowsAmount
        for j in 1:colsAmount
            grid[i, j] = rand(0:100)<=initial_percentage ? 1 : 0
        end
    end
    return grid
end

# Function to count the number of live neighbors
function checkBelow(grid, i, j)
    i==rowsAmount ? 0 :
    grid[i+1, j]==0 ? 2 :
    j!=1&&grid[i+1, j-1]==0 ? 1 :
    j!=colsAmount&&grid[i+1, j+1]==0 ? 3 :
    0
end



function update_grid(grid)
    new_grid = copy(grid)
    for i in 1:rowsAmount
        iInv=rowsAmount-i+1
        for j in 1:colsAmount
            if new_grid[iInv, j]!=0
                where = checkBelow(new_grid, iInv, j)
                if where == 2
                    new_grid[iInv, j] = 0
                    new_grid[iInv+1, j] = 1
                end
                if where == 1 || where == 3
                    new_grid[iInv, j] = 0
                    new_grid[iInv + 1, j + where - 2] = 1
                end
            end
        end
    end
    return new_grid
end

# Function to update the grid and redraw
function update_and_redraw(grid, c)
    println("update")
    #print_grid(grid)    
    grid = update_grid(grid)

    draw(c)

    return grid
end

# Main function to run the game
function run_game()

    grid = initialize_grid()
    # Create the main window
    c = @GtkCanvas()
    win = GtkWindow(c, "Sand", colsAmount*cell_size, rowsAmount*cell_size)

    

    signal_connect(win, "delete-event") do
        println("Exit")
        quit()
    end

    @guarded draw(c) do widget
        ctx = getgc(c)

        set_source_rgb(ctx, 0, 0, 0)
        rectangle(ctx, 0, 0, colsAmount*cell_size, rowsAmount*cell_size)
        fill(ctx)


        for i in 1:rowsAmount
            for j in 1:colsAmount
                if grid[i, j] == 1
                    set_source_rgb(ctx, 1, 1, 0)
                    rectangle(ctx, (j-1)*cell_size+border_size, (i-1)*cell_size+border_size, cell_size-2*border_size, cell_size-2*border_size)
                    fill(ctx)
                end
            end
        end
    end
    c.mouse.button1press = @guarded (widget, event) -> begin
        grid[trunc(Int, event.y/cell_size), trunc(Int, event.x/cell_size)]=1
    end
    show(c)
    # Create a timer to update the grid
    t = Timer((t) -> grid = update_and_redraw(grid, c), 1; interval=time_interval)
    return
end

function print_grid(grid)
    rows, cols = size(grid)
    for i in 1:rows
        for j in 1:cols
            print(grid[i, j] == 1 ? "■ " : "□ ")
        end
        println()
    end
    println()
end



# Run the game
run_game()