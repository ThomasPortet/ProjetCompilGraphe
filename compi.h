typedef struct _node_t {
	int label;
	char *carac;
	struct _node_t *child;
	struct _node_t *right;
} node_t;

typedef struct _list_t {
	node_t *val;
	struct _list_t *next;
} list_t;

int nextlabel();

node_t* makenode(char* carac);
void freenode(node_t* node);
void printnode(node_t* node);

node_t* reverse(node_t* node);

list_t* cons(node_t* node, list_t* list);
void freelist(list_t* list);
void printlist(list_t* list);
