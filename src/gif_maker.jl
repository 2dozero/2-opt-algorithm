function create_gif_with_ffmpeg(image_folder, output_filename)
    # Ensure the output filename ends with .gif
    if !endswith(output_filename, ".gif")
        output_filename *= ".gif"
    end

    # Construct the ffmpeg command
    # Adjust the framerate (fps) as necessary
    ffmpeg_cmd = `ffmpeg -framerate 10 -i $(image_folder)/tour_after_swap_%d.png -vf palettegen=stats_mode=diff $(image_folder)/palette.png`
    run(ffmpeg_cmd)

    # Use the generated palette for better quality GIF
    ffmpeg_cmd_gif = `ffmpeg -framerate 10 -i $(image_folder)/tour_after_swap_%d.png -i $(image_folder)/palette.png -lavfi paletteuse -y $(output_filename)`
    run(ffmpeg_cmd_gif)
    
    # Clean up the palette image
    rm(joinpath(image_folder, "palette.png"))
end

# Example call to the function
create_gif_with_ffmpeg("images", "gif/output.gif")




# function create_gif_with_ffmpeg(image_folder, output_filename)
#     # Ensure the output filename ends with .gif
#     if !endswith(output_filename, ".gif")
#         output_filename *= ".gif"
#     end

#     # Get a list of all the png files in the folder
#     files = filter(x -> occursin("tour_after_swap_", x), readdir(image_folder))

#     # Sort the files based on the number in the filename
#     sort!(files, by = x -> parse(Int, match(r"\d+", x).match))

#     # Copy the last image 10 times to create a delay
#     last_image = files[end]
#     for i in 1:10
#         cp(joinpath(image_folder, last_image), joinpath(image_folder, "delayed_$i.png"))
#     end

#     # Construct the ffmpeg command
#     # Adjust the framerate (fps) as necessary
#     ffmpeg_cmd = `ffmpeg -framerate 10 -i $(image_folder)/tour_after_swap_%d.png -vf palettegen=stats_mode=diff $(image_folder)/palette.png`
#     run(ffmpeg_cmd)

#     # Use the generated palette for better quality GIF
#     ffmpeg_cmd_gif = `ffmpeg -framerate 10 -i $(image_folder)/tour_after_swap_%d.png -i $(image_folder)/palette.png -lavfi paletteuse -y $(output_filename)`
#     run(ffmpeg_cmd_gif)
    
#     # Clean up the palette image and the delayed images
#     rm(joinpath(image_folder, "palette.png"))
#     for i in 1:10
#         rm(joinpath(image_folder, "delayed_$i.png"))
#     end
# end

# # Example call to the function

# create_gif_with_ffmpeg("images", "gif/output.gif")