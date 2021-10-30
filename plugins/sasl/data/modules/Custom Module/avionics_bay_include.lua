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
        int category;           // Category (also range in nm)
        int bearing;            // Check XP documentation, multiplied by 1000
        char region_code[2];
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
        char region_code[2];
        char airport_id[4];
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
    
    
    /** HOLDS **/
    typedef struct xpdata_hold_t {
        const char *id;
        int id_len;
    
        const char *apt_id; // Airport id, ENRT if enroute
        int apt_id_len;
        
        uint8_t navaid_type;    // 11 fix, 2 ndb, 3 VHF (vor, tacan, or dme)
        char turn_direction;    // L or R
    
        char region_code[2];
    
        uint16_t inbound_course;// Inbound magnetic course * 10
        uint16_t leg_time;      // Leg time in seconds. 0 for DME holdings
        uint16_t dme_leg_length;// Leg length in nautical miles * 10
        
        uint32_t max_altitude;  // in feet or 0
        uint32_t min_altitude;  // in feet or 0
    
        uint16_t holding_speed_limit;   // in knots or 0
        
    } xpdata_hold_t;
    
    typedef struct xpdata_hold_array_t {
        const struct xpdata_hold_t * const * holds;
        int len;
    } xpdata_hold_array_t;
    
    
    /** AWYS **/
    typedef struct xpdata_awy_t {
        const char *id;
        int id_len;
    
        const char *start_wpt;
        int start_wpt_len;
        uint8_t start_wpt_type;   // 11 fix, 2 ndb, 3 VHF (vor, tacan, or dme)
        char start_wpt_region_code[2];
    
        const char *end_wpt;
        int end_wpt_len;
        uint8_t end_wpt_type;     // 11 fix, 2 ndb, 3 VHF (vor, tacan, or dme)
        char end_wpt_region_code[2];
    
        uint16_t base_alt;        // in feet * 100
        uint16_t top_alt;         // in feet * 100
    
    } xpdata_awy_t;
    
    typedef struct xpdata_awy_array_t {
        const struct xpdata_awy_t * const * awys;
        int len;
    } xpdata_awy_array_t;
    
    
    /** Triangulation **/
    
    
    typedef struct xpdata_triangulation_t {
        const xpdata_coords_t* points;
        int points_len;
    } xpdata_triangulation_t;
    
    
    /** CIFP **/
    typedef struct xpdata_cifp_leg_t {
        const char *leg_name;   // FIX
        const char *center_fix;
        const char *recomm_navaid;
    
        int center_fix_len;
        int recomm_navaid_len;
        int leg_name_len;
    
        uint32_t radius;          // in nm * 10000
        uint32_t cstr_altitude1;
        uint32_t cstr_altitude2;
        uint32_t cstr_speed;     // Speed in kts
    
        uint16_t theta;           // mag bearing in degees * 10
        uint16_t rho;             // distance in nm * 10
        uint16_t outb_mag;        // Outbound Magnetic Course in degees * 10
        uint16_t rte_hold;        // Route distance / Hold time/dist - distance in nm * 10 
        uint16_t vpath_angle;   // Only for descent, to be considered as negative
    
        char region_code_leg_name[2];
        char region_code_ctr_fix[2];
        char region_code_rec_navaid[2];
    
    
        uint8_t leg_type;         // 1 - IF, 2 - TF, 3 - CF, 4 - DF, 5 - FA, 6 - FC, 7 - FD, 8 - FM, 9 - CA, 10 - CD, 11 - CI, 12 - CR, 13 - RF, 14 - AF, 15 - VA, 16 - VD, 17 - VI, 18 - VM, 19 - VR, 20 - PI, 21 - HA, 22 - HF, 23 - HM
        uint8_t cstr_alt_type;    // see constants
        uint8_t cstr_speed_type; // 0 - not present, 1 at or above, 2 at or below, 3 - at
    
        char turn_direction;      // N - none, L - left, R - right, E - either, M - left required, S - right required, F - either required
    
        bool cstr_altitude1_fl;   // Is it in FL instead of baro ref altitude?
        bool cstr_altitude2_fl;   // Is it in FL instead of baro ref altitude?
    
        bool outb_mag_in_true : 1;    // The outb_mag is in TRUE not mag
        bool rte_hold_in_time : 1;    // The rte_hold is in time not distance (MM.M where M = minutes)
        
        
        bool fly_over_wpt      : 1;   // Is it a fly-over waypoint? If not, it's a fly-by
    
        bool approach_iaf      : 1;   // Initial Approach Fix
        bool approach_if       : 1;   // Intermediate Approach Fix
        bool approach_faf      : 1;   // Final Approach Fix
        bool holding_fix       : 1;   // Is an (approach) holding fix?
        bool first_missed_app  : 1;   // Is first leg of missed approach procedure
    
    } xpdata_cifp_leg_t;
    
    typedef struct xpdata_cifp_data_t {
        char type;
        const char *proc_name;
        int proc_name_len;
        const char *trans_name;
        int trans_name_len;
    
        xpdata_cifp_leg_t *legs;
        int legs_len;
        
        uint32_t transition_altitude;
    
        int _legs_arr_ref;   // For internal use only
        
    } xpdata_cifp_data_t;
    
    typedef struct xpdata_cifp_rwy_data_t {
        int ldg_threshold_alt;
    
        const char *rwy_name;
        int rwy_name_len;
    
        const char *loc_ident;
        int loc_ident_len;
    
        char ils_category;
    
    } xpdata_cifp_rwy_data_t;
    
    
    typedef struct xpdata_cifp_array_t {
        const struct xpdata_cifp_data_t * data;
        int len;
    } xpdata_cifp_array_t;
    
    typedef struct xpdata_cifp_rwy_array_t {
        const struct xpdata_cifp_rwy_data_t * data;
        int len;
    } xpdata_cifp_rwy_array_t;
    
    
    typedef struct xpdata_cifp_t {
        xpdata_cifp_array_t sids;
        xpdata_cifp_array_t stars;
        xpdata_cifp_array_t apprs;
        xpdata_cifp_rwy_array_t rwys;   // This contains extra info compared to no-cifp data
    } xpdata_cifp_t;
        

xpdata_navaid_array_t get_navaid_by_name  (xpdata_navaid_type_t, const char*);
xpdata_navaid_array_t get_navaid_by_freq  (xpdata_navaid_type_t, unsigned int);
xpdata_navaid_array_t get_navaid_by_coords(xpdata_navaid_type_t, double, double);

xpdata_fix_array_t get_fixes_by_name  (const char*);
xpdata_fix_array_t get_fixes_by_coords(double, double);

xpdata_apt_array_t get_apts_by_name  (const char*);
xpdata_apt_array_t get_apts_by_coords(double, double);
const xpdata_apt_t* get_nearest_apt();
void request_apts_details(const char* arpt_id);

int get_mora(double lat, double lon);

void set_acf_coords(double lat, double lon);

xpdata_coords_t get_route_pos(const xpdata_apt_t *apt, int route_id);

xpdata_hold_array_t get_hold_by_id(const char* id);
xpdata_hold_array_t get_hold_by_apt_id(const char* apt_id);

xpdata_awy_array_t get_awy_by_id(const char* id);
xpdata_awy_array_t get_awy_by_start_wpt(const char* wpt_id);
xpdata_awy_array_t get_awy_by_end_wpt(const char* wpt_id);

xpdata_triangulation_t triangulate(const xpdata_apt_node_array_t* array);

xpdata_cifp_t get_cifp(const char* airport_id);
void load_cifp(const char* airport_id);
bool is_cifp_ready();

bool xpdata_is_ready(void);

double get_declination(double lat, double lon, unsigned short year);

bool initialize(const char* xplane_path, const char* plane_path);
const char* get_error(void);
void terminate(void);

]]