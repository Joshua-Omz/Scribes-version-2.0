package respond

import (
	"github.com/gin-gonic/gin"
)

func JSON(c *gin.Context, status int, payload interface{}) {
	if payload != nil {
		c.JSON(status, payload)
	} else {
		c.Status(status)
	}
}

func Error(c *gin.Context, status int, message string) {
	c.JSON(status, gin.H{"error": message})
}
