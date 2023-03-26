#property copyright "Nain"

#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>

namespace Nain
{
    enum EnumSortMode { SORT_MODE_ASC = 1, SORT_MODE_DESC = 2 };

    //-- T must extend ListNumericSortable
    template <typename T> class List : public CArrayObj 
    {
    public:
        bool Add(T *element) { return CArrayObj::Add(element); };
        bool Insert(T *element, const int pos) { return CArrayObj::Insert(element, pos); };
        T *At(const int index) const { return CArrayObj::At(index); };
        bool Update(const int index, T *element) { return CArrayObj::Update(index, element); };
        T *Detach(const int index) { return CArrayObj::Detach(index); };
        bool InsertSort(T *element) { return CArrayObj::InsertSort(element); };
        int Search(const T *element) const { return CArrayObj::Search(element); };
        int SearchGreat(const T *element) const { return CArrayObj::SearchGreat(element); };
        int SearchLess(const T *element) const { return CArrayObj::SearchLess(element); };
        int SearchGreatOrEqual(const T *element) const { return CArrayObj::SearchGreatOrEqual(element); };
        int SearchLessOrEqual(const T *element) const { return CArrayObj::SearchLessOrEqual(element); };
        int SearchFirst(const T *element) const { return CArrayObj::SearchFirst(element); };
        int SearchLast(const T *element) const { return CArrayObj::SearchLast(element); };

        bool AddArray(const List<T> *src) { return CArrayObj::AddArray(src); };
        bool InsertArray(const List<T> *src, const int pos) { return CArrayObj::InsertArray(src, pos); };
        bool AssignArray(const List<T> *src) { return CArrayObj::AssignArray(src); };
        bool CompareArray(const List<T> *array) const { return CArrayObj::CompareArray(array); };

        void Sort(int enumProp, EnumSortMode sortMode)
        {
            for (int i = 0; i < Total(); i++)
                ((ListNumericSortable*)At(i)).EnumPropertyToSort = enumProp;
            
           CArrayObj::Sort(sortMode);
        }

        void Remove(T* element, bool detach = false){
            for (int i = 0; i < Total(); i++)
                if((T*)At(i) == element){
                    if (detach) Detach(i);
                    else Delete(i);
                    return;
                }
        }
   };

    //-- Simplify sorting numeric properties in a CArrayObj by extending this class
    class CNumericSortable : public CObject
    {
    public:
        //mode 1 = ascending / mode 2 = descending
        int Compare(const CObject *node, const int mode = 0) const{
            if(mode <= 0) return 0;
            if(ValueToSort() == ((CNumericSortable*)node).ValueToSort()) return 0;
            int result = (ValueToSort() > ((CNumericSortable*)node).ValueToSort()) * 2 - 1;//NodeValueToCompare(node)
            if(mode == 2) result *= -1;
            return result;
        }

        //-- Return the numeric property which the sorting will be based
        virtual double ValueToSort() const { return 0; }
   };

    //-- Type to use with List<T>
   class ListNumericSortable : public CNumericSortable
    {
    private:
        double ValueToSort() const { return PropValueToSort(EnumPropertyToSort); }
    public:
        int EnumPropertyToSort;
        virtual double PropValueToSort(int enumPropToSort) const { return 0; }
   };

//    class TestClass : ListNumericSortable
//    {
//     public:
//         enum EnumObjProperties { PROPONE, PROPTWO };

//         double PropValueToSort(int enumPropToSort) const {
            
//         }
//    };

    class Position : public ListNumericSortable
    {
    public:
        ulong Ticket; //POSITION_TICKET
        ulong Id; //POSITION_IDENTIFIER
        ulong Magic; //POSITION_MAGIC
        datetime Time; //POSITION_TIME
        datetime TimeUpdate; //POSITION_TIME_UPDATE
        ulong TimeMSC; //POSITION_TIME_MSC
        ulong TimeUpdateMSC; //POSITION_TIME_UPDATE_MSC
        ENUM_POSITION_TYPE Type; //POSITION_TYPE
        ENUM_POSITION_REASON Reason; //POSITION_REASON
        string Symbol; //POSITION_SYMBOL
        string Comment; //POSITION_COMMENT
        string ExternalID; //POSITION_EXTERNAL_ID
        double Volume; //POSITION_VOLUME
        double PriceOpen; //POSITION_PRICE_OPEN
        double SL; //POSITION_SL
        double TP; //POSITION_TP
        double PriceCurrent; //POSITION_PRICE_CURRENT
        double Swap; //POSITION_SWAP
        double Profit; //POSITION_PROFIT
        // double AvgPosPrice;

        enum EnumObjProperties { PROP_TICKET,PROP_ID,PROP_MAGIC,PROP_TIME,PROP_TIMEUPDATE,PROP_TIMEMSC,PROP_TIMEUPDATEMSC,PROP_TYPE,PROP_REASON,
            /*PROP_SYMBOL,PROP_COMMENT,PROP_EXTERNALID,*/PROP_VOLUME,PROP_PRICEOPEN,PROP_SL,PROP_TP,PROP_PRICECURRENT,PROP_SWAP,PROP_PROFIT };
        
        double PropValueToSort(int enumPropToSort) const {
            switch ((EnumObjProperties)enumPropToSort)
            {
                case PROP_TICKET: return Ticket; 
                case PROP_ID: return Id; 
                case PROP_MAGIC: return Magic; 
                case PROP_TIME: return Time; 
                case PROP_TIMEUPDATE: return TimeUpdate; 
                case PROP_TIMEMSC: return TimeMSC; 
                case PROP_TIMEUPDATEMSC: return TimeUpdateMSC; 
                case PROP_TYPE: return Type; 
                case PROP_REASON: return Reason; 
                // case PROP_SYMBOL: return Symbol; 
                // case PROP_COMMENT: return Comment; 
                // case PROP_EXTERNALID: return ExternalID; 
                case PROP_VOLUME: return Volume; 
                case PROP_PRICEOPEN: return PriceOpen; 
                case PROP_SL: return SL; 
                case PROP_TP: return TP; 
                case PROP_PRICECURRENT: return PriceCurrent; 
                case PROP_SWAP: return Swap; 
                case PROP_PROFIT: return Profit; 
            }
            return 0;
        }
    };

    class Order : public ListNumericSortable
    {
    public:
        ulong Ticket; //ORDER_TICKET
        ulong Magic; //ORDER_MAGIC
        ulong PositionId; //ORDER_POSITION_ID
        datetime TimeSetup; //ORDER_TIME_SETUP
        datetime TimeExpiration; //ORDER_TIME_EXPIRATION
        datetime TimeDone; //ORDER_TIME_DONE
        ulong TimeDoneMSC; //ORDER_TIME_DONE_MSC
        ulong TimeSetupMSC; //ORDER_TIME_SETUP_MSC
        ENUM_ORDER_TYPE Type; //ORDER_TYPE
        ENUM_ORDER_STATE State; //ORDER_STATE
        ENUM_ORDER_TYPE_FILLING TypeFilling; //ORDER_TYPE_FILLING
        ENUM_ORDER_TYPE_TIME TypeTime; //ORDER_TYPE_TIME
        ENUM_POSITION_REASON Reason; //ORDER_REASON
        string Symbol; //ORDER_SYMBOL
        string Comment; //ORDER_COMMENT
        string ExternalId; //ORDER_EXTERNAL_ID
        double VolumeCurrent; //ORDER_VOLUME_CURRENT
        double VolumeInitial; //ORDER_VOLUME_INITIAL
        double PriceOpen; //ORDER_PRICE_OPEN
        double PriceStopLimit; //ORDER_PRICE_STOPLIMIT
        double SL; //ORDER_SL
        double TP; //ORDER_TP
        double PriceCurrent; //ORDER_PRICE_CURRENT

        enum EnumObjProperties { PROP_TICKET,PROP_MAGIC,PROP_POSITIONID,PROP_TIMESETUP,PROP_TIMEEXPIRATION,PROP_TIMEDONE,PROP_TIMEDONEMSC,
            PROP_TIMESETUPMSC,PROP_TYPE,PROP_STATE,PROP_TYPEFILLING,PROP_TYPETIME,PROP_REASON,//PROP_SYMBOL,PROP_COMMENT,PROP_EXTERNALID,
            PROP_VOLUMECURRENT,PROP_VOLUMEINITIAL,PROP_PRICEOPEN,PROP_PRICESTOPLIMIT,PROP_SL,PROP_TP,PROP_PRICECURRENT };
        
        double PropValueToSort(int enumPropToSort) const {
            switch ((EnumObjProperties)enumPropToSort)
            {
                case PROP_TICKET: return Ticket;
                case PROP_MAGIC: return Magic;
                case PROP_POSITIONID: return PositionId;
                case PROP_TIMESETUP: return TimeSetup;
                case PROP_TIMEEXPIRATION: return TimeExpiration;
                case PROP_TIMEDONE: return TimeDone;
                case PROP_TIMEDONEMSC: return TimeDoneMSC;
                case PROP_TIMESETUPMSC: return TimeSetupMSC;
                case PROP_TYPE: return Type;
                case PROP_STATE: return State;
                case PROP_TYPEFILLING: return TypeFilling;
                case PROP_TYPETIME: return TypeTime;
                case PROP_REASON: return Reason;
                // case PROP_SYMBOL: return Symbol;
                // case PROP_COMMENT: return Comment;
                // case PROP_EXTERNALID: return ExternalId;
                case PROP_VOLUMECURRENT: return VolumeCurrent;
                case PROP_VOLUMEINITIAL: return VolumeInitial;
                case PROP_PRICEOPEN: return PriceOpen;
                case PROP_PRICESTOPLIMIT: return PriceStopLimit;
                case PROP_SL: return SL;
                case PROP_TP: return TP;
                case PROP_PRICECURRENT: return PriceCurrent ;
            }
            return 0;
        }
    };

    class Deal : public ListNumericSortable
    {
    public:
        // Deal(){}
        // Deal(ulong ticket,ulong order,datetime time,ulong timeMSC,ulong positionId,ulong magic,ENUM_DEAL_REASON reason, 
        //     ENUM_DEAL_ENTRY entry,ENUM_DEAL_TYPE type,string symbol,string comment,string externalId,double volume, 
        //     double price,double profit,double commission,double swap,double fee,double sL,double tP) : 
        //     Ticket(ticket),Order(order),Time(time),TimeMSC(timeMSC),PositionId(positionId),Magic(magic),Reason(reason),
        //     Entry(entry),Type(type),Symbol(symbol),Comment(comment),ExternalId(externalId),Volume(volume),Price(price),
        //     Profit(profit),Commission(commission),Swap(swap),Fee(fee),SL(sL) {}

        ulong Ticket; //DEAL_TICKET
        ulong Order; //DEAL_ORDER
        datetime Time; //DEAL_TIME
        ulong TimeMSC; //DEAL_TIME_MSC
        ulong PositionId; //DEAL_POSITION_ID
        ulong Magic; //DEAL_MAGIC
        ENUM_DEAL_REASON Reason; //DEAL_REASON
        ENUM_DEAL_ENTRY Entry; //DEAL_ENTRY
        ENUM_DEAL_TYPE Type; //DEAL_TYPE
        string Symbol; //DEAL_SYMBOL
        string Comment; //DEAL_COMMENT
        string ExternalId; //DEAL_EXTERNAL_ID
        double Volume; //DEAL_VOLUME
        double Price; //DEAL_PRICE
        double Profit; //DEAL_PROFIT
        double Commission; //DEAL_COMMENT
        double Swap; //DEAL_SWAP
        double Fee; //DEAL_FEE
        double SL; //DEAL_SL
        double TP; //DEAL_TP

        enum EnumObjProperties { PROP_TICKET,PROP_ORDER,PROP_TIME,PROP_TIMEMSC,PROP_POSITIONID,PROP_MAGIC,PROP_REASON,PROP_ENTRY,PROP_TYPE,/*PROP_SYMBOL,
            PROP_COMMENT,PROP_EXTERNALID,*/PROP_VOLUME,PROP_PRICE,PROP_PROFIT,PROP_COMMISSION,PROP_SWAP,PROP_FEE,PROP_SL,PROP_TP };

        virtual double PropValueToSort(int enumPropToSort) const {
            switch ((EnumObjProperties)enumPropToSort)
            {
                case PROP_TICKET: return Ticket; 
                case PROP_ORDER: return Order; 
                case PROP_TIME: return Time; 
                case PROP_TIMEMSC: return TimeMSC; 
                case PROP_POSITIONID: return PositionId; 
                case PROP_MAGIC: return Magic; 
                case PROP_REASON: return Reason; 
                case PROP_ENTRY: return Entry; 
                case PROP_TYPE: return Type; 
                // case PROP_SYMBOL: return Symbol; 
                // case PROP_COMMENT: return Comment; 
                // case PROP_EXTERNALID: return ExternalId; 
                case PROP_VOLUME: return Volume; 
                case PROP_PRICE: return Price; 
                case PROP_PROFIT: return Profit; 
                case PROP_COMMISSION: return Commission; 
                case PROP_SWAP: return Swap; 
                case PROP_FEE: return Fee;
                case PROP_SL: return SL;
                case PROP_TP: return TP;
            }
            return 0;
        }
    };
}