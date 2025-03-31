//Aaryan and Mohit

#include "driver_state.h"
#include <vector>
#include <cstring>

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
    std::vector<data_geometry> objects(state.num_vertices);

    for (int i = 0; i < state.num_vertices; ++i)
    {
        data_vertex v;
        v.data = &state.vertex_data[i * state.floats_per_vertex];

        data_geometry g;
        g.data = new float[state.floats_per_vertex];
        state.vertex_shader(v, g, state.uniform_data);
        objects[i] = g;
    }
    switch(type)
    {
        case render_type::triangle:
        {
            // 1st one
            for(int i=0; i<state.num_vertices-2; i=i+3)
            {
                
                clip_triangle(state, objects[i], objects[i + 1], objects[i + 2]);
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
                clip_triangle(state, objects[idx0], objects[idx1], objects[idx2]);
            }
            break;
        }
        case render_type::fan:
        {
            // For a triangle fan, the first vertex is the center.
            if (state.num_vertices < 3)
                break;

            // Each triangle is (center, vertex[i], vertex[i+1]).
            for (int i = 1; i < state.num_vertices - 1; i++)
            {
                clip_triangle(state, objects[0], objects[i], objects[i+1]);
            }
            break;
        }
        case render_type::strip:
        {
            // For a triangle strip, each new vertex (after the first two)
            // forms a triangle with the previous two.
            if (state.num_vertices < 3)
                break;

            // Each new vertex forms a triangle with the previous two.
            for (int i = 2; i < state.num_vertices-2; i++)
            {
                // 2 cases of even and odd
                if ((i % 2) == 0)
                {
                    clip_triangle(state, objects[i], objects[i+1], objects[i+2]);
                }
                else
                {
                    clip_triangle(state, objects[i], objects[i+2], objects[i+1]);
                }
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
    if (face < 4)
    {
        clip_triangle(state, v0, v1, v2, face + 1);
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

    auto dot_distance = [&](const data_geometry &v, int f)
    {
        if (f == 4)
        {
            return v.gl_Position[2] + v.gl_Position[3];
        }
        else if (f == 5)
        {
            return v.gl_Position[2] - v.gl_Position[3];
        }
        else
        {
            return 0.0f;
        }
    };
    float dd0 = dot_distance(v0, face);
    float dd1 = dot_distance(v1, face);
    float dd2 = dot_distance(v2, face);

    bool a0 = (face == 4) ? (dd0 >= 0) : (dd0 <= 0);
    bool a1 = (face == 4) ? (dd1 >= 0) : (dd1 <= 0);
    bool a2 = (face == 4) ? (dd2 >= 0) : (dd2 <= 0);
    // Count vertices inside the clipping volume
    int inside_count = a0 + a1 + a2;

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
    else if (inside_count == 1)
    {
        // Perform clipping a is the inside one, rest outside
        std::vector<data_geometry> clipped;
        const data_geometry *a, *b, *c;
        // const data_geometry* verts[3] = { &v0, &v1, &v2 };
        // float dists[3] = { d0, d1, d2 };
        
        if(a0)
        {
            a = &v0;
            b = &v1;
            c = &v2;
        }
        else if(a1)
        {
            a = &v1;
            b = &v0;
            c = &v2;
        }
        else
        {
            a = &v2;
            b = &v0;
            c = &v1;
        }
        float d1 = dot_distance(*a, face) / (dot_distance(*a, face) - dot_distance(*b, face));
        float d2 = dot_distance(*a, face) / (dot_distance(*a, face) - dot_distance(*c, face));
        
        data_geometry ans1, ans2;
        ans1.gl_Position = a->gl_Position + d1 * (b->gl_Position - a->gl_Position);
        ans1.data = new float[state.floats_per_vertex];
        for(int i=0; i<state.floats_per_vertex; i++)
        {
            ans1.data[i] = a->data[i] + d1 * (b->data[i] - a->data[i]);
        }

        ans2.gl_Position = a->gl_Position + d2 * (c->gl_Position - a->gl_Position);
        ans2.data = new float[state.floats_per_vertex];
        for(int i=0; i<state.floats_per_vertex; i++)
        {
            ans2.data[i] = a->data[i] + d2 * (c->data[i] - a->data[i]);
        }
        clip_triangle(state, *a, ans1, ans2, face+1);
        
        // Clean up clipped vertices
        delete[] ans1.data;
        delete[] ans2.data;
        for (auto& vertex : clipped)
        {
            delete[] vertex.data;
        }
    }
    else if(inside_count == 2)
    {
       // Perform clipping a and b are the inside one, rest outside
        std::vector<data_geometry> clipped;
        const data_geometry *a, *b, *c;
        if(!a0)
        {
            a = &v1;
            b = &v2;
            c = &v0;
        }
        else if(!a1)
        {
            a = &v0;
            b = &v2;
            c = &v1;
        }
        else
        {
            a = &v0;
            b = &v1;
            c = &v2;
        }
        // Same as above but with only slight variation

        float d1 = dot_distance(*a, face) / (dot_distance(*a, face) - dot_distance(*c, face));
        float d2 = dot_distance(*b, face) / (dot_distance(*b, face) - dot_distance(*c, face));

        data_geometry ans1, ans2;

        ans1.gl_Position = a->gl_Position + d1 * (c->gl_Position - a->gl_Position);
        ans1.data = new float[state.floats_per_vertex];
        for(int i=0; i<state.floats_per_vertex; i++)
        {
            ans1.data[i] = a->data[i] + d1 * (c->data[i] - a->data[i]);
        }

        ans2.gl_Position = b->gl_Position + d2 * (c->gl_Position - b->gl_Position);
        ans2.data = new float[state.floats_per_vertex];
        for(int i=0; i<state.floats_per_vertex; i++)
        {
            ans2.data[i] = b->data[i] + d2 * (c->data[i] - b->data[i]);
        }
        clip_triangle(state, *a, *b, ans1, face+1);
        clip_triangle(state, *b, ans1, ans2, face+1);
        delete[] ans1.data;
        delete[] ans2.data;
    }
}

// Rasterize the triangle defined by the three vertices in the "in" array.  This
// function is responsible for rasterization, interpolation of data to
// fragments, calling the fragment shader, and z-buffering.

float get_coefficients(float xi, float yi, float xj, float yj, float x, float y)
{
    return (yi - yj) * x + (xj - xi) * y + (xi * yj) - (xj * yi);
}

bool edge_handle(float x1, float y1, float x2, float y2)
{
    if ((y1 < y2) || ((y1 == y2) && (x1 < x2)))
    {
        return true;
    }
    else
    {
        return false;
    }
}
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

    float x0 = ((x0_ndc + 1) * 0.5f * state.image_width);
    float y0 = ((y0_ndc + 1) * 0.5f * state.image_height);
    float x1 = ((x1_ndc + 1) * 0.5f * state.image_width);
    float y1 = ((y1_ndc + 1) * 0.5f * state.image_height);
    float x2 = ((x2_ndc + 1) * 0.5f * state.image_width);
    float y2 = ((y2_ndc + 1) * 0.5f * state.image_height);

    // Bounding Box with clipping
    int min_x = floor(std::min({x0, x1, x2}));
    min_x = std::max(0, min_x); // clip to 0

    int max_x = ceil(std::max({x0, x1, x2}));
    max_x = std::min(state.image_width - 1, max_x); // clip to width-1

    int min_y = floor(std::min({y0, y1, y2}));
    min_y = ceil(std::max(0, min_y)); // clip to 0

    int max_y = std::max({y0, y1, y2});
    max_y = std::min(state.image_height-1, max_y); // clip to height-1

    float w0 = 1.0f / v0.gl_Position[3];
    float w1 = 1.0f / v1.gl_Position[3];
    float w2 = 1.0f / v2.gl_Position[3];

    float z0_ndc = v0.gl_Position[2] / v0.gl_Position[3];
    float z1_ndc = v1.gl_Position[2] / v1.gl_Position[3];
    float z2_ndc = v2.gl_Position[2] / v2.gl_Position[3];

    float f_alpha = get_coefficients(x1, y1, x2, y2, x0, y0);
    float f_beta = get_coefficients(x2, y2, x0, y0, x1, y1);
    float f_gamma = 1 - f_alpha - f_beta;

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
            float alpha, beta, gamma, w_perspective, px, py;
            px = x + 0.5f;
            py = y + 0.5f;
            alpha = get_coefficients(x1, y1, x2, y2, px, py) / f_alpha;
            beta = get_coefficients(x2, y2, x0, y0, px, py) / f_beta;
            gamma = 1.0f - alpha - beta;
            if((alpha > 0 || (alpha == 0 && edge_handle(x1, y1, x2, y2))))
            {
                if((beta > 0 || (beta == 0 && edge_handle(x2, y2, x0, y0))))
                {
                    if((gamma > 0 || (gamma == 0 && edge_handle(x0, y0, x1, y1))))
                    {
                        // Inside
                        float denomW = alpha * w0 + beta * w1 + gamma * w2;
                        if(std::abs(denomW) < 1e-6) // denominator close to 0
                        {
                            // Skip this pixel
                            continue;
                        }
                        w_perspective = 1.0f / denomW;
                        // float depth = (alpha * (v0.gl_Position[2]) * w0 + beta * (v1.gl_Position[2]) * w1 + gamma * (v2.gl_Position[2]) * w2);
                        float depth = w_perspective * (alpha * v0.gl_Position[2]*w0 + beta * v1.gl_Position[2]*w1 + gamma * v2.gl_Position[2]*w2);
                        // float depth = (alpha * z0_ndc * w0 + beta * z1_ndc * w1 + gamma * z2_ndc * w2) * w_perspective;
                        int pixel_index = y * state.image_width + x;
                        if(depth < state.image_depth[pixel_index])
                        {
                            // Fragment Shader
                            data_fragment fragment{new float[state.floats_per_vertex]};
                            data_output output;
                            // fragment.data = new float[state.floats_per_vertex];
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
                                        float w_perspective = 1.0f / (alpha * w0 + beta * w1 + gamma * w2);
                                        fragment.data[i] = w_perspective * (alpha*v0.data[i]*w0 + beta*v1.data[i]*w1 + gamma*v2.data[i]*w2);
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
                            state.image_depth[pixel_index] = depth;
                            delete[] fragment.data;
                        }
                    }
                }
            }
        }
    }
    // std::cout<<"TODO: implement rasterization"<<std::endl;
}

