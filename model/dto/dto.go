package dto

type BaseDto struct {
	PageNum   *int64 `json:"pageNum" form:"pageNum" validate:"required,gt=0"`      // Page number
	PageSize  *int64 `json:"pageSize" form:"pageSize" validate:"required,gt=0"`    // Page size
	StartTime *int64 `json:"startTime" form:"startTime" validate:"omitempty,gt=0"` // Start time
	EndTime   *int64 `json:"endTime" form:"endTime" validate:"omitempty,gt=0"`     // End time
}

type IdDto struct {
	Id *int64 `json:"id" form:"id" validate:"required,gt=0"` // Primary key
}
