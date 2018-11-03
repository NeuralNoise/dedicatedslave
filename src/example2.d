class smart_ptr {
> private:
> 	A* _ptr;
> 
> public:
> 	this(A* ptr) {
> 		void* buffer = GC.malloc(A.sizeof);
> 		memcpy(buffer, ptr, A.sizeof);
> 
> 		this._ptr = cast(A*) buffer;
> 	}
> 
> 	~this() {
> 		GC.free(this._ptr);
> 	}
> 
> 	@property
> 	A* Ptr() {
> 		return this._ptr;
> 	}
> 
> 	alias Ptr this;
> }