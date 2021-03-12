return [[

typedef int xpdata_navaid_type_t;

typedef struct xpdata_coords_t {
    double lat;
    double lon;
} xpdata_coords_t;

/******************************* NAVAIDS *******************************/
typedef struct xpdata_navaid_t {
    const char *id;         // e.g., SRN
    int id_len;
    const char *full_name;  // e.g., Saronno VOR
    int full_name_len;
    xpdata_navaid_type_t type; // Constants NAV_ID_* 
    xpdata_coords_t coords;
    int altitude;
    unsigned int frequency;
    bool is_coupled_dme;    // True if the vor is coupled with DME
} xpdata_navaid_t;

typedef struct xpdata_navaid_array_t {
    const struct xpdata_navaid_t * const * navaids;
    int len;
} xpdata_navaid_array_t;

/******************************* FIXES *******************************/
typedef struct xpdata_fix_t {
    const char *id;         // e.g., ROMEO
    int id_len;
    xpdata_coords_t coords;
} xpdata_fix_t;

typedef struct xpdata_fix_array_t {
    const struct xpdata_fix_t * const * fixes;
    int len;
} xpdata_fix_array_t;

/******************************* ARPT *******************************/

typedef struct xpdata_apt_rwy_t {
    char name[4];
    char sibl_name[4];              // On the other head of the runway

    xpdata_coords_t coords;
    xpdata_coords_t sibl_coords;    // On the other head of the runway
    
    double width;
    int surface_type;
    bool has_ctr_lights;
    
} xpdata_apt_rwy_t;

typedef struct xpdata_apt_node_t {

    xpdata_coords_t coords;
    bool is_bez;
    xpdata_coords_t bez_cp;

} xpdata_apt_node_t;

typedef struct xpdata_apt_node_array_t {
    int color;
    
    xpdata_apt_node_t *nodes;
    int nodes_len;
    
    struct xpdata_apt_node_array_t *hole; // For linear feature this value is nullptr
} xpdata_apt_node_array_t;

typedef struct xpdata_apt_route_t {
    const char *name;
    int name_len;
    int route_node_1;   // Identifiers for the route nodes, to be used with get_route_node()
    int route_node_2;   // Identifiers for the route nodes, to be used with get_route_node()
} xpdata_apt_route_t;

typedef struct xpdata_apt_gate_t {
    const char *name;
    int name_len;
    xpdata_coords_t coords;
} xpdata_apt_gate_t;

typedef struct xpdata_apt_details_t {
    xpdata_coords_t tower_pos; 

    xpdata_apt_node_array_t *pavements;
    int pavements_len;
    
    xpdata_apt_node_array_t *linear_features;
    int linear_features_len;

    xpdata_apt_node_array_t *boundaries;
    int boundaries_len;

    xpdata_apt_route_t *routes;
    int routes_len;

    xpdata_apt_gate_t  *gates;
    int gates_len;

} xpdata_apt_details_t;

typedef struct xpdata_apt_t {
    const char *id;         // e.g., LIRF
    int id_len;
    
    const char *full_name;  // e.g., Roma Fiumicino
    int full_name_len;
    
    int altitude;

    const xpdata_apt_rwy_t *rwys;
    int rwys_len;
    
    xpdata_coords_t apt_center;
    
    long pos_seek;   // For internal use only, do not modify this value
    
    bool is_loaded_details;
    xpdata_apt_details_t *details;
    
} xpdata_apt_t;

typedef struct xpdata_apt_array_t {
    const struct xpdata_apt_t * const * apts;
    int len;
} xpdata_apt_array_t;


typedef struct xpdata_triangulation_t {
    const xpdata_coords_t* points;
    int points_len;
} xpdata_triangulation_t;

bool initialize(const char* xplane_path, const char* plane_path);
const char* get_error(void);
void terminate(void);
xpdata_navaid_array_t get_navaid_by_name  (xpdata_navaid_type_t, const char*);
xpdata_navaid_array_t get_navaid_by_freq  (xpdata_navaid_type_t, unsigned int);
xpdata_navaid_array_t get_navaid_by_coords(xpdata_navaid_type_t, double, double);

xpdata_fix_array_t get_fixes_by_name  (const char*);
xpdata_fix_array_t get_fixes_by_coords(double, double);

xpdata_apt_array_t get_apts_by_name  (const char*);
xpdata_apt_array_t get_apts_by_coords(double, double);

const xpdata_apt_t* get_nearest_apt();
void set_acf_coords(double lat, double lon);
void request_apts_details(const char* arpt_id);
xpdata_coords_t get_route_pos(const xpdata_apt_t *apt, int route_id);
xpdata_triangulation_t triangulate(const xpdata_apt_node_array_t* array);
bool xpdata_is_ready(void);

]]
