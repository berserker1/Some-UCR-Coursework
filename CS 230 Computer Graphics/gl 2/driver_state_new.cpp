// File modified by Bhagya Patel and Rishi Patel
#include "driver_state.h"
#include <cstring>
#include <vector>
#include <algorithm>

driver_state::driver_state()
{
}

driver_state::~driver_state()
{
    delete[] image_color;
    delete[] image_depth;
}

// This function should allocate and initialize the arrays that store color and
// depth.  This is not done during the constructor since the width and height
// are not known when this class is constructed.
void initialize_render(driver_state &state, int width, int height)
{
    state.image_width = width;
    state.image_height = height;
    state.image_color = 0;
    state.image_depth = 0;

    state.image_color = new pixel[width * height];
    state.image_depth = new float[width * height];

    // Color the image black
    for (int i = 0; i < width * height; i++)
    {
        state.image_color[i] = make_pixel(0, 0, 0);
    }

    for (int i = 0; i < width * height; ++i)
    {
        state.image_depth[i] = std::numeric_limits<float>::infinity(); // Set to max depth
    }
}

// This function will be called to render the data that has been stored in this class.
// Valid values of type are:
//   render_type::triangle - Each group of three vertices corresponds to a triangle.
//   render_type::indexed -  Each group of three indices in index_data corresponds
//                           to a triangle.  These numbers are indices into vertex_data.
//   render_type::fan -      The vertices are to be interpreted as a triangle fan.
//   render_type::strip -    The vertices are to be interpreted as a triangle strip.
void render(driver_state &state, render_type type)
{
    std::vector<data_geometry> geometries(state.num_vertices);

    for (int i = 0; i < state.num_vertices; ++i)
    {
        data_vertex v;
        v.data = &state.vertex_data[i * state.floats_per_vertex];

        data_geometry g;
        g.data = new float[state.floats_per_vertex];
        state.vertex_shader(v, g, state.uniform_data);
        geometries[i] = g;
    }

    switch (type)
    {
    case render_type::triangle:
        // Render as a list of triangles
        for (int i = 0; i < state.num_vertices - 2; i += 3)
        {
            clip_triangle(state, geometries[i], geometries[i + 1], geometries[i + 2]);
        }
        break;
    case render_type::indexed:
        // Render as indexed triangles
        for (int i = 0; i < state.num_triangles; ++i)
        {
            int index0 = state.index_data[i * 3];
            int index1 = state.index_data[i * 3 + 1];
            int index2 = state.index_data[i * 3 + 2];
            clip_triangle(state, geometries[index0], geometries[index1], geometries[index2]);
        }
        break;
    case render_type::fan:
        // Render as a triangle fan
        for (int i = 1; i < state.num_vertices - 1; ++i)
        {
            clip_triangle(state, geometries[0], geometries[i], geometries[i + 1]);
        }
        break;
    case render_type::strip:
        // Render as a triangle strip
        for (int i = 0; i < state.num_vertices - 2; ++i)
        {
            if (i % 2 == 0)
            {
                clip_triangle(state, geometries[i], geometries[i + 1], geometries[i + 2]);
            }
            else
            {
                clip_triangle(state, geometries[i], geometries[i + 2], geometries[i + 1]);
            }
        }
        break;
    default:
        break;
    }
}

// This function clips a triangle (defined by the three vertices in the "in" array).
// It will be called recursively, once for each clipping face (face=0, 1, ..., 5) to
// clip against each of the clipping faces in turn.  When face=6, clip_triangle should
// simply pass the call on to rasterize_triangle.
void clip_triangle(driver_state &state, const data_geometry &v0,
                   const data_geometry &v1, const data_geometry &v2, int face)
{
    if (face == 6)
    {
        rasterize_triangle(state, v0, v1, v2);
        return;
    }

    // Only handle near (face 4) and far (face 5) planes; pass others through
    if (face < 4)
    {
        clip_triangle(state, v0, v1, v2, face + 1);
        return;
    }

    auto compute_distance = [&](const data_geometry &v, int f)
    {
        if (f == 4) // Near plane: z + w >= 0
            return v.gl_Position[2] + v.gl_Position[3];
        else if (f == 5) // Far plane: z - w <= 0
            return v.gl_Position[2] - v.gl_Position[3];
        return 0.0f;
    };

    float d0 = compute_distance(v0, face);
    float d1 = compute_distance(v1, face);
    float d2 = compute_distance(v2, face);

    bool in0 = (face == 4) ? (d0 >= 0) : (d0 <= 0);
    bool in1 = (face == 4) ? (d1 >= 0) : (d1 <= 0);
    bool in2 = (face == 4) ? (d2 >= 0) : (d2 <= 0);

    int num_in = in0 + in1 + in2;

    if (num_in == 0)
    {
        // All vertices outside; discard the triangle
        return;
    }
    else if (num_in == 3)
    {
        // All vertices inside; proceed to next face
        clip_triangle(state, v0, v1, v2, face + 1);
        return;
    }

    // Helper function to interpolate vertices
    auto interpolate = [&](const data_geometry &a, const data_geometry &b, float t)
    {
        data_geometry res;
        res.gl_Position = a.gl_Position + t * (b.gl_Position - a.gl_Position);
        res.data = new float[state.floats_per_vertex];
        for (int i = 0; i < state.floats_per_vertex; ++i)
        {
            res.data[i] = a.data[i] + t * (b.data[i] - a.data[i]);
        }
        return res;
    };

    if (num_in == 1)
    {
        // One vertex inside; create two new vertices
        const data_geometry *in_v, *out_v1, *out_v2;
        if (in0)
        {
            in_v = &v0;
            out_v1 = &v1;
            out_v2 = &v2;
        }
        else if (in1)
        {
            in_v = &v1;
            out_v1 = &v0;
            out_v2 = &v2;
        }
        else
        {
            in_v = &v2;
            out_v1 = &v0;
            out_v2 = &v1;
        }

        float t1 = compute_distance(*in_v, face) / (compute_distance(*in_v, face) - compute_distance(*out_v1, face));
        float t2 = compute_distance(*in_v, face) / (compute_distance(*in_v, face) - compute_distance(*out_v2, face));

        data_geometry p1 = interpolate(*in_v, *out_v1, t1);
        data_geometry p2 = interpolate(*in_v, *out_v2, t2);

        clip_triangle(state, *in_v, p1, p2, face + 1);

        delete[] p1.data;
        delete[] p2.data;
    }
    else if (num_in == 2)
    {
        // Two vertices inside; create two new triangles
        const data_geometry *out_v, *in_v1, *in_v2;
        if (!in0)
        {
            out_v = &v0;
            in_v1 = &v1;
            in_v2 = &v2;
        }
        else if (!in1)
        {
            out_v = &v1;
            in_v1 = &v0;
            in_v2 = &v2;
        }
        else
        {
            out_v = &v2;
            in_v1 = &v0;
            in_v2 = &v1;
        }

        float t1 = compute_distance(*in_v1, face) / (compute_distance(*in_v1, face) - compute_distance(*out_v, face));
        float t2 = compute_distance(*in_v2, face) / (compute_distance(*in_v2, face) - compute_distance(*out_v, face));

        data_geometry p1 = interpolate(*in_v1, *out_v, t1);
        data_geometry p2 = interpolate(*in_v2, *out_v, t2);

        clip_triangle(state, *in_v1, *in_v2, p1, face + 1);
        clip_triangle(state, *in_v2, p1, p2, face + 1);

        delete[] p1.data;
        delete[] p2.data;
    }
}

float get_fij(float xi, float yi, float xj, float yj, float x, float y)
{
    return (yi - yj) * x + (xj - xi) * y + (xi * yj) - (xj * yi);
}

bool is_top_left(float x1, float y1, float x2, float y2)
{
    return (y1 < y2) || (y1 == y2 && x1 < x2);
}
// Rasterize the triangle defined by the three vertices in the "in" array.  This
// function is responsible for rasterization, interpolation of data to
// fragments, calling the fragment shader, and z-buffering.
void rasterize_triangle(driver_state &state, const data_geometry &v0,
                        const data_geometry &v1, const data_geometry &v2)
{
    // Extract x and y coordinates from the homogeneous coordinates,
    // performing the perspective divide.
    float x0 = v0.gl_Position[0] / v0.gl_Position[3];
    float y0 = v0.gl_Position[1] / v0.gl_Position[3];

    x0 = (x0 * 0.5f + 0.5f) * state.image_width;
    y0 = (y0 * 0.5f + 0.5f) * state.image_height;

    float x1 = v1.gl_Position[0] / v1.gl_Position[3];
    float y1 = v1.gl_Position[1] / v1.gl_Position[3];

    x1 = (x1 * 0.5f + 0.5f) * state.image_width;
    y1 = (y1 * 0.5f + 0.5f) * state.image_height;

    float x2 = v2.gl_Position[0] / v2.gl_Position[3];
    float y2 = v2.gl_Position[1] / v2.gl_Position[3];

    x2 = (x2 * 0.5f + 0.5f) * state.image_width;
    y2 = (y2 * 0.5f + 0.5f) * state.image_height;

    // Image dimensions
    int image_width = state.image_width;
    int image_height = state.image_height;

    // Bounding box
    int xmin = floor(std::min({x0, x1, x2}));
    int xmax = ceil(std::max({x0, x1, x2}));
    int ymin = floor(std::min({y0, y1, y2}));
    int ymax = ceil(std::max({y0, y1, y2}));

    // Clip to screen bounds
    xmin = std::max(xmin, 0);
    xmax = std::min(xmax, image_width - 1);
    ymin = std::max(ymin, 0);
    ymax = std::min(ymax, image_height - 1);

    // Edge function coefficients
    float f_alpha = get_fij(x1, y1, x2, y2, x0, y0);
    float f_beta = get_fij(x2, y2, x0, y0, x1, y1);
    float f_gamma = get_fij(x0, y0, x1, y1, x2, y2);

    // Loop through pixels in bounding box
    for (int y = ymin; y <= ymax; ++y)
    {
        for (int x = xmin; x <= xmax; ++x)
        {
            float px = x + 0.5f;
            float py = y + 0.5f;
            // Edge function values at pixel centers
            float alpha = get_fij(x1, y1, x2, y2, px, py) / f_alpha;
            float beta = get_fij(x2, y2, x0, y0, px, py) / f_beta;
            float gamma = get_fij(x0, y0, x1, y1, px, py) / f_gamma;

            // Check if inside triangle (before perspective correction)
            if ((alpha > 0 || (alpha == 0 && is_top_left(x1, y1, x2, y2))) &&
                (beta > 0 || (beta == 0 && is_top_left(x2, y2, x0, y0))) &&
                (gamma > 0 || (gamma == 0 && is_top_left(x0, y0, x1, y1))))
            {
                // Perspective correction
                float w0 = 1.0f / v0.gl_Position[3];
                float w1 = 1.0f / v1.gl_Position[3];
                float w2 = 1.0f / v2.gl_Position[3];

                float sum_w = alpha * w0 + beta * w1 + gamma * w2;
                float alpha_corrected = alpha * w0 / sum_w;
                float beta_corrected = beta * w1 / sum_w;
                float gamma_corrected = gamma * w2 / sum_w;

                // Interpolate depth (z-value)

                float z0 = v0.gl_Position[2];
                float z1 = v1.gl_Position[2];
                float z2 = v2.gl_Position[2];

                float interpolated_depth = alpha_corrected * z0 + beta_corrected * z1 + gamma_corrected * z2;

                // Z-buffering (depth test)
                int pixel_index = y * image_width + x;
                if (interpolated_depth < state.image_depth[pixel_index])
                {
                    // Interpolate attributes and call fragment shader
                    data_fragment in;
                    in.data = new float[state.floats_per_vertex];

                    for (int i = 0; i < state.floats_per_vertex; ++i)
                    {
                        switch (state.interp_rules[i])
                        {
                        case interp_type::invalid:
                            break;
                        case interp_type::flat:
                            in.data[i] = v0.data[i]; // Flat interpolation
                            break;
                        case interp_type::smooth:
                            // Perspective-correct interpolation
                            in.data[i] = alpha_corrected * v0.data[i] +
                                         beta_corrected * v1.data[i] +
                                         gamma_corrected * v2.data[i];
                            break;
                        case interp_type::noperspective:
                            // No perspective interpolation (barycentric coordinates)
                            float sum = alpha + beta + gamma;
                            float alpha_norm = alpha / sum;
                            float beta_norm = beta / sum;
                            float gamma_norm = gamma / sum;
                            in.data[i] = alpha_norm * v0.data[i] +
                                         beta_norm * v1.data[i] +
                                         gamma_norm * v2.data[i];
                            break;
                        }
                    }

                    data_output out;
                    state.fragment_shader(in, out, state.uniform_data);

                    float r = out.output_color[0] * 255;
                    float g = out.output_color[1] * 255;
                    float b = out.output_color[2] * 255;

                    // Write color to image
                    state.image_color[pixel_index] = make_pixel(r, g, b);

                    // Update depth buffer
                    state.image_depth[pixel_index] = interpolated_depth;

                    delete[] in.data; // Clean up allocated memory
                }
            }
        }
    }
}