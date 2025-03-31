#include "driver_state.h"
#include <vector>
#include <cstring>
//mohit
//aaryan
driver_state::driver_state()
{
    image_color = nullptr;
    image_depth = nullptr;
}

driver_state::~driver_state()
{
    delete [] image_color;
    delete [] image_depth;
}

// This function should allocate and initialize the arrays that store color and
// depth.  This is not done during the constructor since the width and height
// are not known when this class is constructed.
void initialize_render(driver_state& state, int width, int height)
{
    state.image_width=width;
    state.image_height=height;

    // Freeing old memory first
    // Freeing old memory first
    if(state.image_color)
    {
        delete[] state.image_color;
        state.image_color = nullptr;
    }
    if(state.image_depth)
    {
        delete[] state.image_depth;
        state.image_depth = nullptr;
    }


    state.image_color=new pixel[width * height];
    state.image_depth=new float[width * height];
    for(int i=0; i<width * height; i++)
    {
        state.image_color[i] = make_pixel(0, 0, 0); // Initialize with black
        state.image_depth[i] = 1.0f; // max depth
    }
    // std::cout<<"TODO: allocate and initialize state.image_color and state.image_depth."<<std::endl;
}

// This function will be called to render the data that has been stored in this class.
// Valid values of type are:
//   render_type::triangle - Each group of three vertices corresponds to a triangle.
//   render_type::indexed -  Each group of three indices in index_data corresponds
//                           to a triangle.  These numbers are indices into vertex_data.
//   render_type::fan -      The vertices are to be interpreted as a triangle fan.
//   render_type::strip -    The vertices are to be interpreted as a triangle strip.
void render(driver_state& state, render_type type)
{
    switch(type)
    {
        case render_type::triangle:
        {
            // 1st one
            for(int i=0; i<state.num_vertices; i=i+3)
            {
                data_geometry a, b, c;
                // float *i_a = state.vertex_data + i*state.floats_per_vertex;
                // float *i_b = state.vertex_data + (i+1)*state.floats_per_vertex;
                // float *i_c = state.vertex_data + (i+2)*state.floats_per_vertex;

                // // We will pass data of type float * as of type data_vertex
                // // data_vertex is nothing but a struct containing float *
                // // hence we will pass to vertex_shader as {float *}

                // state.vertex_shader({i_a}, a, state.uniform_data);
                // state.vertex_shader({i_b}, b, state.uniform_data);
                // state.vertex_shader({i_c}, c, state.uniform_data);
                a.data = new float[state.floats_per_vertex];
                b.data = new float[state.floats_per_vertex];
                c.data = new float[state.floats_per_vertex];

                std::copy(
                    state.vertex_data + (i) * state.floats_per_vertex,
                    state.vertex_data + (i + 1) * state.floats_per_vertex,
                    a.data
                );
                    // Run vertex shader
                state.vertex_shader(
                    {state.vertex_data + (i) * state.floats_per_vertex},
                    a,
                    state.uniform_data
                );
                std::copy(
                    state.vertex_data + (i + 1) * state.floats_per_vertex,
                    state.vertex_data + (i + 2) * state.floats_per_vertex,
                    b.data
                );
                    // Run vertex shader
                state.vertex_shader(
                    {state.vertex_data + (i + 1) * state.floats_per_vertex},
                    b,
                    state.uniform_data
                );
                std::copy(
                    state.vertex_data + (i + 2) * state.floats_per_vertex,
                    state.vertex_data + (i + 3) * state.floats_per_vertex,
                    c.data
                );
                    // Run vertex shader
                state.vertex_shader(
                    {state.vertex_data + (i + 2) * state.floats_per_vertex},
                    c,
                    state.uniform_data
                );
                clip_triangle(state, a, b, c);
                delete [] a.data;
                delete [] b.data;
                delete [] c.data;
            }
            break;
        }
        case render_type::indexed:
        {
            // For indexed rendering, each group of 3 indices in index_data specifies a triangle.
            for (int i = 0; i < state.num_triangles; i++)
            {
                int idx0 = state.index_data[i * 3 + 0];
                int idx1 = state.index_data[i * 3 + 1];
                int idx2 = state.index_data[i * 3 + 2];

                data_geometry g0, g1, g2;
                float* v0 = state.vertex_data + idx0 * state.floats_per_vertex;
                float* v1 = state.vertex_data + idx1 * state.floats_per_vertex;
                float* v2 = state.vertex_data + idx2 * state.floats_per_vertex;

                state.vertex_shader({ v0 }, g0, state.uniform_data);
                state.vertex_shader({ v1 }, g1, state.uniform_data);
                state.vertex_shader({ v2 }, g2, state.uniform_data);

                clip_triangle(state, g0, g1, g2, 0);
            }
            break;
        }
        case render_type::fan:
        {
            // For a triangle fan, the first vertex is the center.
            if (state.num_vertices < 3)
                break;

            data_geometry center;
            float* center_ptr = state.vertex_data; // first vertex
            state.vertex_shader({ center_ptr }, center, state.uniform_data);

            // Each triangle is (center, vertex[i], vertex[i+1]).
            for (int i = 1; i < state.num_vertices - 1; i++)
            {
                data_geometry g1, g2;
                float* v1 = state.vertex_data + i * state.floats_per_vertex;
                float* v2 = state.vertex_data + (i + 1) * state.floats_per_vertex;
                state.vertex_shader({ v1 }, g1, state.uniform_data);
                state.vertex_shader({ v2 }, g2, state.uniform_data);

                clip_triangle(state, center, g1, g2, 0);
            }
            break;
        }
        case render_type::strip:
        {
            // For a triangle strip, each new vertex (after the first two)
            // forms a triangle with the previous two.
            if (state.num_vertices < 3)
                break;

            // Process the first two vertices.
            data_geometry prev0, prev1;
            float* v0 = state.vertex_data;
            float* v1 = state.vertex_data + state.floats_per_vertex;
            state.vertex_shader({ v0 }, prev0, state.uniform_data);
            state.vertex_shader({ v1 }, prev1, state.uniform_data);

            // Each new vertex forms a triangle with the previous two.
            for (int i = 2; i < state.num_vertices; i++)
            {
                data_geometry curr;
                float* v = state.vertex_data + i * state.floats_per_vertex;
                state.vertex_shader({ v }, curr, state.uniform_data);

                // For even triangles, the vertices are ordered as (prev0, prev1, curr);
                // for odd triangles, swap prev0 and prev1.
                if ((i % 2) == 0)
                {
                    clip_triangle(state, prev0, prev1, curr, 0);
                }
                else
                {
                    clip_triangle(state, prev1, prev0, curr, 0);
                }
                // Shift the previous two vertices.
                prev0 = prev1;
                prev1 = curr;
            }
            break;
        }
        case render_type::invalid:
        {
            std::cout << "Invalid render_type exiting" << std::endl;
            break;
        }
    }
    // std::cout<<"TODO: implement rendering."<<std::endl;
}


// This function clips a triangle (defined by the three vertices in the "in" array).
// It will be called recursively, once for each clipping face (face=0, 1, ..., 5) to
// clip against each of the clipping faces in turn.  When face=6, clip_triangle should
// simply pass the call on to rasterize_triangle.

void clip_triangle(driver_state& state, const data_geometry& v0,
    const data_geometry& v1, const data_geometry& v2,int face)
{
    if (face == 6) {
        // If all clipping planes have been processed, rasterize the triangle.
        rasterize_triangle(state, v0, v1, v2);
        return;
    }

    // Define the six clipping planes in NDC
    const vec4 planes[6] = {
        { 1,  0,  0, 1}, // x = w
        {-1,  0,  0, 1}, // x = -w
        { 0,  1,  0, 1}, // y = w
        { 0, -1,  0, 1}, // y = -w
        { 0,  0,  1, 1}, // z = w
        { 0,  0, -1, 1}  // z = -w
    };

    // Compute signed distances to the clipping plane
    float d0 = dot(planes[face], v0.gl_Position);
    float d1 = dot(planes[face], v1.gl_Position);
    float d2 = dot(planes[face], v2.gl_Position);

    // Count vertices inside the clipping volume
    int inside_count = (d0 >= 0) + (d1 >= 0) + (d2 >= 0);

    if (inside_count == 3)
    {
        // All vertices are inside; continue clipping against the next plane
        clip_triangle(state, v0, v1, v2, face + 1);
    }
    else if (inside_count == 0)
    {
        // All vertices are outside; discard the triangle
        return;
    }
    else
    {
        // Perform clipping
        std::vector<data_geometry> clipped;
        const data_geometry* verts[3] = { &v0, &v1, &v2 };
        float dists[3] = { d0, d1, d2 };
        
        for (int i = 0; i < 3; ++i)
        {
            int next = (i + 1) % 3;
            const data_geometry* v_curr = verts[i];
            const data_geometry* v_next = verts[next];
            
            if (dists[i] >= 0)
            {
                data_geometry new_v;
                new_v.data = new float[state.floats_per_vertex];
                new_v.gl_Position = verts[i]->gl_Position;
                std::copy(verts[i]->data, verts[i]->data + state.floats_per_vertex, new_v.data);
                clipped.push_back(new_v);
            }
            
            if ((dists[i] >= 0) != (dists[next] >= 0))
            {
                float t = dists[i] / (dists[i] - dists[next]);
                data_geometry v_interp;
                v_interp.data = new float[state.floats_per_vertex];
                v_interp.gl_Position = v_curr->gl_Position + t * (v_next->gl_Position - v_curr->gl_Position);
                
                // Interpolate other attributes
                for (int j = 0; j < state.floats_per_vertex; j++)
                {
                    v_interp.data[j] = v_curr->data[j] + t * (v_next->data[j] - v_curr->data[j]);
                }
                clipped.push_back(v_interp);
            }
        }
        
        // Triangulate the clipped polygon
        for (size_t i = 1; i + 1 < clipped.size(); i++)
        {
            clip_triangle(state, clipped[0], clipped[i], clipped[i + 1], face + 1);
        }
    }
}

// Rasterize the triangle defined by the three vertices in the "in" array.  This
// function is responsible for rasterization, interpolation of data to
// fragments, calling the fragment shader, and z-buffering.
void rasterize_triangle(driver_state& state, const data_geometry& v0,
    const data_geometry& v1, const data_geometry& v2)
{

    // // Convert to screen coordinates
    float x0_ndc = v0.gl_Position[0] / v0.gl_Position[3]; 
    float y0_ndc = v0.gl_Position[1] / v0.gl_Position[3]; 
    float x1_ndc = v1.gl_Position[0] / v1.gl_Position[3]; 
    float y1_ndc = v1.gl_Position[1] / v1.gl_Position[3]; 
    float x2_ndc = v2.gl_Position[0] / v2.gl_Position[3]; 
    float y2_ndc = v2.gl_Position[1] / v2.gl_Position[3];

    int x0 = static_cast<int>((x0_ndc + 1) * 0.5f * state.image_width);
    int y0 = static_cast<int>((y0_ndc + 1) * 0.5f * state.image_height);
    int x1 = static_cast<int>((x1_ndc + 1) * 0.5f * state.image_width);
    int y1 = static_cast<int>((y1_ndc + 1) * 0.5f * state.image_height);
    int x2 = static_cast<int>((x2_ndc + 1) * 0.5f * state.image_width);
    int y2 = static_cast<int>((y2_ndc + 1) * 0.5f * state.image_height);

    // Bounding Box with clipping
    int min_x = std::min({x0, x1, x2});
    min_x = std::max(0, min_x); // clip to 0

    int max_x = std::max({x0, x1, x2});
    max_x = std::min(state.image_width - 1, max_x); // clip to width-1

    int min_y = std::min({y0, y1, y2});
    min_y = std::max(0, min_y); // clip to 0

    int max_y = std::max({y0, y1, y2});
    max_y = std::min(state.image_height-1, max_y); // clip to height-1

    float w0 = 1.0f / v0.gl_Position[3];
    float w1 = 1.0f / v1.gl_Position[3];
    float w2 = 1.0f / v2.gl_Position[3];
    float denom = (x1 - x0) * (y2 - y0) - (x2 - x0) * (y1 - y0);
    if(std::abs(denom - 0.0f) < 1e-6) // denominator close to 0
    {
        // Skip
        return;
    }
    // Iterate over pixels
    for(int y=min_y; y<=max_y; y++)
    {
        for(int x=min_x; x<=max_x; x++)
        {
            // Computing barycentric coordinates
            float alpha, beta, gamma, w_perspective;
            alpha = ((y1 - y2) * (x - x2) + (x2 - x1) * (y - y2)) / denom;
            beta = ((y2 - y0) * (x - x2) + (x0 - x2) * (y - y2)) / denom;
            gamma = 1.0f - alpha - beta;
            if((alpha>=0) && (beta>=0) && (gamma>= 0)) // Inside
            {
                w_perspective = 1.0f / (alpha * w0 + beta * w1 + gamma * w2);
                float depth = (alpha * v0.gl_Position[2] * w0 + beta * v1.gl_Position[2] * w1 + gamma * v2.gl_Position[2] * w2);
                int pixel_index = y * state.image_width + x;
                if(depth < state.image_depth[pixel_index])
                {
                    state.image_depth[pixel_index] = depth;
                    // Fragment Shader
                    data_fragment fragment{new float[state.floats_per_vertex]};
                    data_output output;
                    fragment.data = new float[state.floats_per_vertex];
                    for(int i=0; i<state.floats_per_vertex; i++)
                    {
                        switch(state.interp_rules[i])
                        {
                            case interp_type::flat:
                            {
                                fragment.data[i] = v0.data[i];
                                break;
                            }
                            case interp_type::noperspective:
                            {
                                fragment.data[i] = alpha*v0.data[i] + beta*v1.data[i] + gamma*v2.data[i];
                                break;
                            }
                            case interp_type::smooth:
                            {
                                // float total = alpha*w0 + beta*w1 + gamma*w2;
                                fragment.data[i] = w_perspective * (alpha*v0.data[i] + beta*v1.data[i] + gamma*v2.data[i]);
                                break;
                            }
                            case interp_type::invalid:
                            {
                                std::cout << "invalid Interp_type exiting" << std::endl;
                                break;
                            }
                        }
                    }
                    // Converting into uint_8
                    // Clamped between 0 and 255
                    state.fragment_shader(fragment, output, state.uniform_data);
                    int r_val = std::min(255, std::max(0, static_cast<int>(output.output_color[0] * 255)));
                    int g_val = std::min(255, std::max(0, static_cast<int>(output.output_color[1] * 255)));
                    int b_val = std::min(255, std::max(0, static_cast<int>(output.output_color[2] * 255)));
                    state.image_color[pixel_index] = make_pixel(r_val, g_val, b_val);
                    delete[] fragment.data;
                }
            }
        }
    }
    // std::cout<<"TODO: implement rasterization"<<std::endl;
}

